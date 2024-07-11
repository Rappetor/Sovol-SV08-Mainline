
from . import probe
import math
import configparser, os

class ZoffsetCalibration:
    def __init__(self, config):
        self.printer = config.get_printer()
        self.config = config
        x_pos_center, y_pos_center = config.getfloatlist("center_xy_position", count=2)
        x_pos_endstop, y_pos_endstop = config.getfloatlist("endstop_xy_position", count=2)
        self.center_x_pos, self.center_y_pos = x_pos_center, y_pos_center
        self.endstop_x_pos, self.endstop_y_pos = x_pos_endstop, y_pos_endstop
        self.z_hop = config.getfloat("z_hop", default=10.0)
        self.z_hop_speed = config.getfloat('z_hop_speed', 5., above=0.)
        zconfig = config.getsection('stepper_z')
        self.endstop_pin = zconfig.get('endstop_pin')
        self.speed = config.getfloat('speed', 180.0, above=0.)
        self.internalendstopoffset = config.getfloat('internalendstopoffset', 0.75)
        self.gcode = self.printer.lookup_object('gcode')
        self.gcode_move = self.printer.lookup_object('gcode_move')
        self.gcode.register_command("Z_OFFSET_CALIBRATION", self.cmd_Z_OFFSET_CALIBRATION, desc=self.cmd_Z_OFFSET_CALIBRATION_help)

        # Let's grab the path and filename for the save_variables from the printer.cfg and make sure we also use the userpath ~/ if it's in there.
        self.saved_variables_filename = os.path.expanduser(self.config.getsection('save_variables').get('filename'))
        
        # add reference to the probe for later use
        self.probe = probe
        
        # check if a probe is installed
        if config.has_section("probe"):
            probe_cfg = config.getsection('probe')
            self.x_offset = probe_cfg.getfloat('x_offset', note_valid=False)
            self.y_offset = probe_cfg.getfloat('y_offset', note_valid=False)
            # check if a possible valid offset is set for probe
            if ((self.x_offset == 0) and (self.y_offset == 0)):
                raise config.error("ZoffsetCalibration: Check the x and y offset from [probe] - it seems both are 0 and the Probe can't be at the same position as the nozzle :-)")
            
            probe_pressure = config.getsection('probe_pressure')
            self.x_offsetp = probe_pressure.getfloat('x_offset', note_valid=False)
            self.y_offsetp = probe_pressure.getfloat('y_offset', note_valid=False)

        else:
            raise config.error("ZoffsetCalibration: probe in configured in your system - check your setup.")
        
    def read_varibles_cfg_value(self, option):
        _config = configparser.ConfigParser()
        _config.read(self.saved_variables_filename) # grab the saved_variables file..
        _value = _config.get('Variables', option)
        return _value

    # custom round operation based mathematically instead of python default cutting off
    def rounding(self,n, decimals=0):
        expoN = n * 10 ** decimals
        if abs(expoN) - abs(math.floor(expoN)) < 0.5:
            return math.floor(expoN) / 10 ** decimals
        return math.ceil(expoN) / 10 ** decimals


    def cmd_Z_OFFSET_CALIBRATION(self, gcmd):
    
        # (re)load the offsetadjust from the e.g. saved_variables.cfg, so we always get the most up-to-date value!
        offsetadjust = float(self.read_varibles_cfg_value("offsetadjust"))
        
        # check if all axes are homed
        toolhead = self.printer.lookup_object('toolhead')
        curtime = self.printer.get_reactor().monotonic()
        kin_status = toolhead.get_kinematics().get_status(curtime)

        gcmd_offset = self.gcode.create_gcode_command("SET_GCODE_OFFSET",
                                                      "SET_GCODE_OFFSET",
                                                      {'Z': 0})
        self.gcode_move.cmd_SET_GCODE_OFFSET(gcmd_offset)
    
        gcmd.respond_info("ZoffsetCalibration: Pressure move ...")
        toolhead.manual_move([self.endstop_x_pos, self.endstop_y_pos], self.speed)

        gcmd.respond_info("ZoffsetCalibration: Pressure lookup object ...")
        zendstop_p = self.printer.lookup_object('probe_pressure').run_probe(gcmd)
        # Perform Z Hop
        if self.z_hop:
            toolhead.manual_move([None, None, 5], 5)
            
        gcmd.respond_info("ZoffsetCalibration: Pressure lookup object ...")
        zendstop_p1 = self.printer.lookup_object('probe_pressure').run_probe(gcmd)
        # Perform Z Hop
        if self.z_hop:
            toolhead.manual_move([None, None, self.z_hop], self.z_hop_speed)
            
        # Move with probe to endstop XY position and test surface z position
        gcmd.respond_info("ZoffsetCalibration: Probing endstop ...")
        toolhead.manual_move([self.endstop_x_pos - self.x_offset, self.endstop_y_pos - self.y_offset], self.speed)
        # zendstop_P2 = self.printer.lookup_object('probe').run_probe(gcmd)
        zendstop_P2 = self.probe.run_single_probe(self.printer.lookup_object('probe'), gcmd)
        
        
        # Perform Z Hop
        if self.z_hop:
            toolhead.manual_move([None, None, self.z_hop], self.z_hop_speed)
        # Move with probe to center XY position and test surface z position
        gcmd.respond_info("ZoffsetCalibration: Probing bed ...")
        toolhead.manual_move([self.center_x_pos, self.center_y_pos], self.speed)
        # zbed = self.printer.lookup_object('probe').run_probe(gcmd)
        zbed = self.probe.run_single_probe(self.printer.lookup_object('probe'), gcmd)
        # Perform Z Hop
        if self.z_hop:
            toolhead.manual_move([None, None, self.z_hop], self.z_hop_speed)  
            
        px,py,pz = self.printer.lookup_object('probe').get_offsets()
        
        probe_pressure_z = (float(zendstop_p[2]) + float(zendstop_p1[2]))/2
        probe_z = float(zendstop_P2[2]) 
        diffbedendstop =  probe_pressure_z - probe_z

        offset = self.rounding((diffbedendstop - self.internalendstopoffset) + offsetadjust + pz,3)
        gcmd.respond_info("ZoffsetCalibration:\nprobe_pressure_z: %.3f\nprobe_z: %.3f\nDiff: %.3f\nConfig Manual Adjust: %.3f\nTotal Calculated Offset: %.3f" % (probe_pressure_z,probe_z,diffbedendstop,offsetadjust,offset,))
            
        self.set_offset(offset)
        
    def set_offset(self, offset):
        # reset pssible existing offset to zero
        gcmd_offset = self.gcode.create_gcode_command("SET_GCODE_OFFSET",
                                                      "SET_GCODE_OFFSET",
                                                      {'Z': 0})
        self.gcode_move.cmd_SET_GCODE_OFFSET(gcmd_offset)
        # set new offset
        gcmd_offset = self.gcode.create_gcode_command("SET_GCODE_OFFSET",
                                                      "SET_GCODE_OFFSET",
                                                      {'Z': offset})
        self.gcode_move.cmd_SET_GCODE_OFFSET(gcmd_offset)

    cmd_Z_OFFSET_CALIBRATION_help = "Test endstop and bed surface to calcualte g-code offset for Z"
    

def load_config(config):
    return ZoffsetCalibration(config)

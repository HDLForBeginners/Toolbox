# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  #Adding Group
  set FPGA_IP [ipgui::add_group $IPINST -name "FPGA IP" -parent ${Page_0} -layout horizontal]
  ipgui::add_param $IPINST -name "FPGA_IP_1" -parent ${FPGA_IP} -show_range false
  ipgui::add_param $IPINST -name "FPGA_IP_2" -parent ${FPGA_IP} -show_label false
  ipgui::add_param $IPINST -name "FPGA_IP_3" -parent ${FPGA_IP} -show_label false -show_range false
  ipgui::add_param $IPINST -name "FPGA_IP_4" -parent ${FPGA_IP} -show_label false -show_range false

  #Adding Group
  set HOST_IP [ipgui::add_group $IPINST -name "HOST IP" -parent ${Page_0} -layout horizontal]
  ipgui::add_param $IPINST -name "HOST_IP_1" -parent ${HOST_IP} -show_range false
  ipgui::add_param $IPINST -name "HOST_IP_2" -parent ${HOST_IP} -show_label false -show_range false
  ipgui::add_param $IPINST -name "HOST_IP_3" -parent ${HOST_IP} -show_label false -show_range false
  ipgui::add_param $IPINST -name "HOST_IP_4" -parent ${HOST_IP} -show_label false -show_range false

  #Adding Group
  set PORTS [ipgui::add_group $IPINST -name "PORTS" -parent ${Page_0}]
  ipgui::add_param $IPINST -name "FPGA_PORT" -parent ${PORTS}
  ipgui::add_param $IPINST -name "HOST_PORT" -parent ${PORTS}

  #Adding Group
  set MAC_ADDRESSES [ipgui::add_group $IPINST -name "MAC ADDRESSES" -parent ${Page_0}]
  ipgui::add_param $IPINST -name "FPGA_MAC" -parent ${MAC_ADDRESSES}
  ipgui::add_param $IPINST -name "HOST_MAC" -parent ${MAC_ADDRESSES}

  ipgui::add_param $IPINST -name "HEADER_CHECKSUM" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CHECK_DESTINATION" -parent ${Page_0}


}

proc update_PARAM_VALUE.CHECK_DESTINATION { PARAM_VALUE.CHECK_DESTINATION } {
	# Procedure called to update CHECK_DESTINATION when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CHECK_DESTINATION { PARAM_VALUE.CHECK_DESTINATION } {
	# Procedure called to validate CHECK_DESTINATION
	return true
}

proc update_PARAM_VALUE.FPGA_IP_1 { PARAM_VALUE.FPGA_IP_1 } {
	# Procedure called to update FPGA_IP_1 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FPGA_IP_1 { PARAM_VALUE.FPGA_IP_1 } {
	# Procedure called to validate FPGA_IP_1
	return true
}

proc update_PARAM_VALUE.FPGA_IP_2 { PARAM_VALUE.FPGA_IP_2 } {
	# Procedure called to update FPGA_IP_2 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FPGA_IP_2 { PARAM_VALUE.FPGA_IP_2 } {
	# Procedure called to validate FPGA_IP_2
	return true
}

proc update_PARAM_VALUE.FPGA_IP_3 { PARAM_VALUE.FPGA_IP_3 } {
	# Procedure called to update FPGA_IP_3 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FPGA_IP_3 { PARAM_VALUE.FPGA_IP_3 } {
	# Procedure called to validate FPGA_IP_3
	return true
}

proc update_PARAM_VALUE.FPGA_IP_4 { PARAM_VALUE.FPGA_IP_4 } {
	# Procedure called to update FPGA_IP_4 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FPGA_IP_4 { PARAM_VALUE.FPGA_IP_4 } {
	# Procedure called to validate FPGA_IP_4
	return true
}

proc update_PARAM_VALUE.FPGA_MAC { PARAM_VALUE.FPGA_MAC } {
	# Procedure called to update FPGA_MAC when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FPGA_MAC { PARAM_VALUE.FPGA_MAC } {
	# Procedure called to validate FPGA_MAC
	return true
}

proc update_PARAM_VALUE.FPGA_PORT { PARAM_VALUE.FPGA_PORT } {
	# Procedure called to update FPGA_PORT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FPGA_PORT { PARAM_VALUE.FPGA_PORT } {
	# Procedure called to validate FPGA_PORT
	return true
}

proc update_PARAM_VALUE.HEADER_CHECKSUM { PARAM_VALUE.HEADER_CHECKSUM } {
	# Procedure called to update HEADER_CHECKSUM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.HEADER_CHECKSUM { PARAM_VALUE.HEADER_CHECKSUM } {
	# Procedure called to validate HEADER_CHECKSUM
	return true
}

proc update_PARAM_VALUE.HOST_IP_1 { PARAM_VALUE.HOST_IP_1 } {
	# Procedure called to update HOST_IP_1 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.HOST_IP_1 { PARAM_VALUE.HOST_IP_1 } {
	# Procedure called to validate HOST_IP_1
	return true
}

proc update_PARAM_VALUE.HOST_IP_2 { PARAM_VALUE.HOST_IP_2 } {
	# Procedure called to update HOST_IP_2 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.HOST_IP_2 { PARAM_VALUE.HOST_IP_2 } {
	# Procedure called to validate HOST_IP_2
	return true
}

proc update_PARAM_VALUE.HOST_IP_3 { PARAM_VALUE.HOST_IP_3 } {
	# Procedure called to update HOST_IP_3 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.HOST_IP_3 { PARAM_VALUE.HOST_IP_3 } {
	# Procedure called to validate HOST_IP_3
	return true
}

proc update_PARAM_VALUE.HOST_IP_4 { PARAM_VALUE.HOST_IP_4 } {
	# Procedure called to update HOST_IP_4 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.HOST_IP_4 { PARAM_VALUE.HOST_IP_4 } {
	# Procedure called to validate HOST_IP_4
	return true
}

proc update_PARAM_VALUE.HOST_MAC { PARAM_VALUE.HOST_MAC } {
	# Procedure called to update HOST_MAC when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.HOST_MAC { PARAM_VALUE.HOST_MAC } {
	# Procedure called to validate HOST_MAC
	return true
}

proc update_PARAM_VALUE.HOST_PORT { PARAM_VALUE.HOST_PORT } {
	# Procedure called to update HOST_PORT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.HOST_PORT { PARAM_VALUE.HOST_PORT } {
	# Procedure called to validate HOST_PORT
	return true
}


proc update_MODELPARAM_VALUE.FPGA_PORT { MODELPARAM_VALUE.FPGA_PORT PARAM_VALUE.FPGA_PORT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FPGA_PORT}] ${MODELPARAM_VALUE.FPGA_PORT}
}

proc update_MODELPARAM_VALUE.HOST_PORT { MODELPARAM_VALUE.HOST_PORT PARAM_VALUE.HOST_PORT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.HOST_PORT}] ${MODELPARAM_VALUE.HOST_PORT}
}

proc update_MODELPARAM_VALUE.FPGA_MAC { MODELPARAM_VALUE.FPGA_MAC PARAM_VALUE.FPGA_MAC } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FPGA_MAC}] ${MODELPARAM_VALUE.FPGA_MAC}
}

proc update_MODELPARAM_VALUE.HOST_MAC { MODELPARAM_VALUE.HOST_MAC PARAM_VALUE.HOST_MAC } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.HOST_MAC}] ${MODELPARAM_VALUE.HOST_MAC}
}

proc update_MODELPARAM_VALUE.FPGA_IP_1 { MODELPARAM_VALUE.FPGA_IP_1 PARAM_VALUE.FPGA_IP_1 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FPGA_IP_1}] ${MODELPARAM_VALUE.FPGA_IP_1}
}

proc update_MODELPARAM_VALUE.FPGA_IP_2 { MODELPARAM_VALUE.FPGA_IP_2 PARAM_VALUE.FPGA_IP_2 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FPGA_IP_2}] ${MODELPARAM_VALUE.FPGA_IP_2}
}

proc update_MODELPARAM_VALUE.FPGA_IP_3 { MODELPARAM_VALUE.FPGA_IP_3 PARAM_VALUE.FPGA_IP_3 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FPGA_IP_3}] ${MODELPARAM_VALUE.FPGA_IP_3}
}

proc update_MODELPARAM_VALUE.FPGA_IP_4 { MODELPARAM_VALUE.FPGA_IP_4 PARAM_VALUE.FPGA_IP_4 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FPGA_IP_4}] ${MODELPARAM_VALUE.FPGA_IP_4}
}

proc update_MODELPARAM_VALUE.HOST_IP_1 { MODELPARAM_VALUE.HOST_IP_1 PARAM_VALUE.HOST_IP_1 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.HOST_IP_1}] ${MODELPARAM_VALUE.HOST_IP_1}
}

proc update_MODELPARAM_VALUE.HOST_IP_2 { MODELPARAM_VALUE.HOST_IP_2 PARAM_VALUE.HOST_IP_2 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.HOST_IP_2}] ${MODELPARAM_VALUE.HOST_IP_2}
}

proc update_MODELPARAM_VALUE.HOST_IP_3 { MODELPARAM_VALUE.HOST_IP_3 PARAM_VALUE.HOST_IP_3 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.HOST_IP_3}] ${MODELPARAM_VALUE.HOST_IP_3}
}

proc update_MODELPARAM_VALUE.HOST_IP_4 { MODELPARAM_VALUE.HOST_IP_4 PARAM_VALUE.HOST_IP_4 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.HOST_IP_4}] ${MODELPARAM_VALUE.HOST_IP_4}
}

proc update_MODELPARAM_VALUE.HEADER_CHECKSUM { MODELPARAM_VALUE.HEADER_CHECKSUM PARAM_VALUE.HEADER_CHECKSUM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.HEADER_CHECKSUM}] ${MODELPARAM_VALUE.HEADER_CHECKSUM}
}

proc update_MODELPARAM_VALUE.CHECK_DESTINATION { MODELPARAM_VALUE.CHECK_DESTINATION PARAM_VALUE.CHECK_DESTINATION } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CHECK_DESTINATION}] ${MODELPARAM_VALUE.CHECK_DESTINATION}
}


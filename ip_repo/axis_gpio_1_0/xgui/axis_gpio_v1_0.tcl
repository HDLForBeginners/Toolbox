# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Switches_in [ipgui::add_page $IPINST -name "Switches in"]
  ipgui::add_param $IPINST -name "PREFIX_CHARS" -parent ${Switches_in}
  ipgui::add_param $IPINST -name "POSTFIX_CHARS" -parent ${Switches_in}
  ipgui::add_param $IPINST -name "PREFIX_STRING" -parent ${Switches_in}
  ipgui::add_param $IPINST -name "POSTFIX_STRING" -parent ${Switches_in}
  ipgui::add_param $IPINST -name "AXI_OUT_WIDTH" -parent ${Switches_in}
  set INCLUDE_CRLF [ipgui::add_param $IPINST -name "INCLUDE_CRLF" -parent ${Switches_in}]
  set_property tooltip {Include Carriage Return and Line Feed at end of line} ${INCLUDE_CRLF}

  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0" -display_name {LEDs out}]
  set_property tooltip {LEDs out} ${Page_0}
  ipgui::add_param $IPINST -name "BYTE_START" -parent ${Page_0}
  ipgui::add_param $IPINST -name "GPIO_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "AXI_WIDTH" -parent ${Page_0}


}

proc update_PARAM_VALUE.AXI_OUT_WIDTH { PARAM_VALUE.AXI_OUT_WIDTH } {
	# Procedure called to update AXI_OUT_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_OUT_WIDTH { PARAM_VALUE.AXI_OUT_WIDTH } {
	# Procedure called to validate AXI_OUT_WIDTH
	return true
}

proc update_PARAM_VALUE.AXI_WIDTH { PARAM_VALUE.AXI_WIDTH } {
	# Procedure called to update AXI_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXI_WIDTH { PARAM_VALUE.AXI_WIDTH } {
	# Procedure called to validate AXI_WIDTH
	return true
}

proc update_PARAM_VALUE.BYTE_START { PARAM_VALUE.BYTE_START } {
	# Procedure called to update BYTE_START when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BYTE_START { PARAM_VALUE.BYTE_START } {
	# Procedure called to validate BYTE_START
	return true
}

proc update_PARAM_VALUE.GPIO_WIDTH { PARAM_VALUE.GPIO_WIDTH } {
	# Procedure called to update GPIO_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.GPIO_WIDTH { PARAM_VALUE.GPIO_WIDTH } {
	# Procedure called to validate GPIO_WIDTH
	return true
}

proc update_PARAM_VALUE.INCLUDE_CRLF { PARAM_VALUE.INCLUDE_CRLF } {
	# Procedure called to update INCLUDE_CRLF when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INCLUDE_CRLF { PARAM_VALUE.INCLUDE_CRLF } {
	# Procedure called to validate INCLUDE_CRLF
	return true
}

proc update_PARAM_VALUE.POSTFIX_CHARS { PARAM_VALUE.POSTFIX_CHARS } {
	# Procedure called to update POSTFIX_CHARS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.POSTFIX_CHARS { PARAM_VALUE.POSTFIX_CHARS } {
	# Procedure called to validate POSTFIX_CHARS
	return true
}

proc update_PARAM_VALUE.POSTFIX_STRING { PARAM_VALUE.POSTFIX_STRING } {
	# Procedure called to update POSTFIX_STRING when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.POSTFIX_STRING { PARAM_VALUE.POSTFIX_STRING } {
	# Procedure called to validate POSTFIX_STRING
	return true
}

proc update_PARAM_VALUE.PREFIX_CHARS { PARAM_VALUE.PREFIX_CHARS } {
	# Procedure called to update PREFIX_CHARS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PREFIX_CHARS { PARAM_VALUE.PREFIX_CHARS } {
	# Procedure called to validate PREFIX_CHARS
	return true
}

proc update_PARAM_VALUE.PREFIX_STRING { PARAM_VALUE.PREFIX_STRING } {
	# Procedure called to update PREFIX_STRING when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PREFIX_STRING { PARAM_VALUE.PREFIX_STRING } {
	# Procedure called to validate PREFIX_STRING
	return true
}


proc update_MODELPARAM_VALUE.PREFIX_CHARS { MODELPARAM_VALUE.PREFIX_CHARS PARAM_VALUE.PREFIX_CHARS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PREFIX_CHARS}] ${MODELPARAM_VALUE.PREFIX_CHARS}
}

proc update_MODELPARAM_VALUE.POSTFIX_CHARS { MODELPARAM_VALUE.POSTFIX_CHARS PARAM_VALUE.POSTFIX_CHARS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.POSTFIX_CHARS}] ${MODELPARAM_VALUE.POSTFIX_CHARS}
}

proc update_MODELPARAM_VALUE.PREFIX_STRING { MODELPARAM_VALUE.PREFIX_STRING PARAM_VALUE.PREFIX_STRING } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PREFIX_STRING}] ${MODELPARAM_VALUE.PREFIX_STRING}
}

proc update_MODELPARAM_VALUE.POSTFIX_STRING { MODELPARAM_VALUE.POSTFIX_STRING PARAM_VALUE.POSTFIX_STRING } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.POSTFIX_STRING}] ${MODELPARAM_VALUE.POSTFIX_STRING}
}

proc update_MODELPARAM_VALUE.GPIO_WIDTH { MODELPARAM_VALUE.GPIO_WIDTH PARAM_VALUE.GPIO_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.GPIO_WIDTH}] ${MODELPARAM_VALUE.GPIO_WIDTH}
}

proc update_MODELPARAM_VALUE.AXI_OUT_WIDTH { MODELPARAM_VALUE.AXI_OUT_WIDTH PARAM_VALUE.AXI_OUT_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_OUT_WIDTH}] ${MODELPARAM_VALUE.AXI_OUT_WIDTH}
}

proc update_MODELPARAM_VALUE.INCLUDE_CRLF { MODELPARAM_VALUE.INCLUDE_CRLF PARAM_VALUE.INCLUDE_CRLF } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INCLUDE_CRLF}] ${MODELPARAM_VALUE.INCLUDE_CRLF}
}

proc update_MODELPARAM_VALUE.BYTE_START { MODELPARAM_VALUE.BYTE_START PARAM_VALUE.BYTE_START } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BYTE_START}] ${MODELPARAM_VALUE.BYTE_START}
}

proc update_MODELPARAM_VALUE.AXI_WIDTH { MODELPARAM_VALUE.AXI_WIDTH PARAM_VALUE.AXI_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXI_WIDTH}] ${MODELPARAM_VALUE.AXI_WIDTH}
}


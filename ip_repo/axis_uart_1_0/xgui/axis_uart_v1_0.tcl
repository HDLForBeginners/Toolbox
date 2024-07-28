# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "CLKRATE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "BAUD" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WORD_LENGTH" -parent ${Page_0}


}

proc update_PARAM_VALUE.BAUD { PARAM_VALUE.BAUD } {
	# Procedure called to update BAUD when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BAUD { PARAM_VALUE.BAUD } {
	# Procedure called to validate BAUD
	return true
}

proc update_PARAM_VALUE.CLKRATE { PARAM_VALUE.CLKRATE } {
	# Procedure called to update CLKRATE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CLKRATE { PARAM_VALUE.CLKRATE } {
	# Procedure called to validate CLKRATE
	return true
}

proc update_PARAM_VALUE.WORD_LENGTH { PARAM_VALUE.WORD_LENGTH } {
	# Procedure called to update WORD_LENGTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WORD_LENGTH { PARAM_VALUE.WORD_LENGTH } {
	# Procedure called to validate WORD_LENGTH
	return true
}


proc update_MODELPARAM_VALUE.CLKRATE { MODELPARAM_VALUE.CLKRATE PARAM_VALUE.CLKRATE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CLKRATE}] ${MODELPARAM_VALUE.CLKRATE}
}

proc update_MODELPARAM_VALUE.BAUD { MODELPARAM_VALUE.BAUD PARAM_VALUE.BAUD } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BAUD}] ${MODELPARAM_VALUE.BAUD}
}

proc update_MODELPARAM_VALUE.WORD_LENGTH { MODELPARAM_VALUE.WORD_LENGTH PARAM_VALUE.WORD_LENGTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WORD_LENGTH}] ${MODELPARAM_VALUE.WORD_LENGTH}
}


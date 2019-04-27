# Remaps my audio card to a mono input (otherwise it only outputs on the left channel)
pactl load-module module-remap-source\
	master=alsa_input.usb-E-MU_Systems__Inc._E-MU_0404___USB_E-MU-93-FFFF-07D60915-1083C-STN_02-00.iec958-stereo\
	master_channel_map=front-left,front-right\
	channel_map=mono,mono\
	source_name="E-MU_mono_remap"\
	source_properties="device.description=E-MU_mono_remap"

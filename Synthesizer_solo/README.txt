<<< 			R E A D M E			>>>
<<< Radar Intensity Heatmap and Depth Image Synthesizer	>>>
<<<		-----	Single CAD	-----		>>>
<<< 			02/19/2022			>>>


---- Basic Steps ----

1. set up parameters in the 3 variable libraries
2. specify the object and number of dataset in toplevel.m
	(make sure you have the point cloud 
		of the object in CAD folder)
3. run toplevel.m


---- File Hierarchy ---

|= CAD			# folder to store CAD point cloud models
|= results		# folder to store synthesized results
	|= objName_idx
		|= cartHeat	# 3D cartesian intensity maps
		|= fig		# 2D depth images
			|= 1280x720
				|= cam1
				|= cam2
				|= ...
|= scripts		# folder to store synthesizer scripts
	|- toplevel.m			# specify object and amount 
	|- variable_library.m		# scenario parameters
	|- variable_library_radar.m	# radar parameters
	|- variable_library_camera.m	# camera parameters
	|= functions_main
		|- main.m			# the synthesizer 
		|- remove_occlusion.m		# get points of visiable surface
		|- model_point_reflector.m	# model radar reflectors
		|- add_evn_noise.m		# add noise points to radar
		|- simulate_radar_signal.m	# simlate signals
		|- radar_dsp(2ss).m		# generate spherical intensity maps
		|- Sph2CartHeat.m		# convert 3d maps (spherical->Cartesian)
	|= functions_Sph2Cart
		|- sph2cart_pts.m	# find center pts of sph voxels in Cartesian
		|- matchHeat.m		# match values of sph voxels to Cartesian
		|- sph2cart_heat.m	# map values of sph voxels to Cartesian voxels
	|= functions_helper
		|- checkOS.m		# check OS to determine slashes for directory
		|- CreateResultFolder 	# create folders to store results
		|- dispElpTime.m	# disp used time





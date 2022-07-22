# mmWave-Depth-Synthesizer
 Data synthesizer for generating mmWave radar intensity 3D maps and 2D depth images

## Based on [Hawkeye's data synthesizer](https://github.com/JaydenG1019/HawkEye-Data-Code)

## More about [CAD models](https://github.com/zhuoming34/CAD-Model-PointCloud)

## Versions
- **solo**: one object
- **duo**: two objects
- **trio**: three objects
- **universal**: choice of one/two/three objects 

**For more objects**, modify the following files:
- **toplevel.m**
- **variable_library_scene.m**
  - add new **translate_lim**
- **main.m**
  - add placements for new objects
  - (refer to duo/trio)
- **labelImg.m**
  - add labels for new objects
- **CreateResultFolder.m**
  - add new object names and indices
- **logging.m**
  - add new object names, indice, and boundaries

### more details for README will be added soon

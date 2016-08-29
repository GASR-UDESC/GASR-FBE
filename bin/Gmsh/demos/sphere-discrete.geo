// merge a surface mesh (any format will work: .msh, .unv, etc.)

Merge "sphere-surf.stl";

// add a geometrical volume

Surface Loop(1) = {1};
Volume(1) = {1};

// use this to force a coarse mesh inside
//Mesh.CharacteristicLengthExtendFromBoundary = 0;
//Mesh.CharacteristicLengthMax = 0.5;

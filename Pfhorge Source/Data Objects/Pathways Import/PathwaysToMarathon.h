//
// PathwaysToMarathon.h
// Pfhorge
//
// Converts a map from the format of
// Pathways into Darkness
// into Pfhorge's internal format
// for the Marathon series
//
// Originally written by Loren Petrich

#import "PathwaysMapSaveData.h"
#import "LELevelData.h"


NSString *GetLevelName(PID_Level& PL);

LELevelData *PathwaysToMarathon(PID_Level& PL, PID_LevelState& PLS);

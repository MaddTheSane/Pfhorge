#include <stdio.h>
#include <stdbool.h>

int LoadShapes(FILE *f, int depth);
int LoadCollection(int coll, FILE *f);
void UnloadCollection(int coll);
bool CollIsLoaded(int coll);
int DecodeShapesClut(int coll, int clutID, int *outColorNum, rgb_color_value **outColors);
int DecodeShapesBitmap(int coll, int bitmapID, int *outW, int *outH, short *outFlags, unsigned char **outPixData);
int GetNumberOfBitmapsInCollection(int coll, int *theBitmapCount);

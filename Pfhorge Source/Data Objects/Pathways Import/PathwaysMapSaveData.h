//
// PathwaysMapSaveData.h
// Pfhorge
//
// Pathways into Darkness (game by Bungie Studios)
// Map, Savegame, and Initial-Condition Data Definitions
//
// Originally written by Loren Petrich


#import "PhTypesStructresEnums.h"


// Set the data alignment to be convenient for PID's data structures;
// that is, completely packed.
// This is done to save coding time.
#pragma pack(push, 2)


// Door:
// 8 bytes
struct PID_Door {

	// Which way does the door open?
	enum open_direction: short {
		X_Negative,
		Y_Negative,
		X_Positive,
		Y_Positive,
		NUMBER_OF_DIRECTIONS
	};
	
	// Its coordinates
	short x, y;
	
	// Its direction of opening
	open_direction Direction;
	
	// Texture ID?
	short Texture;
};


// Level-change dispatch
// 8 bytes
struct PID_LevelChange {
	
	// The types:
	enum level_change_type: short {
		Upward,
		Downward,
		SecretDownward,
		SecretUpward,
		NUMBER_OF_TYPES
	};
	// The reversal of order is odd, but it checks out

	// The type of change to make
	level_change_type Type;
	
	// The level to go to
	short Level;
	
	// The coordinates of the sector to go to
	short x, y;
};


// Monster presence; indicates which kind present and how often they reappear
// 4 bytes
struct PID_Monster {
	
	enum pid_monster_type: short {
		None=-1,
		
		Nightmare,
		Headless,
		Phantasm,
		Ghoul,
		Zombie,
		
		Ooze,
		Wraith,
		ShockingSphere,
		BlueMeanie,
		Barney,
		
		Skitter,
		Sentinel,
		Ghast,
		GreenOoze,
		Demon,
		
		GreaterNightmare,
		VenomousSkitter,
		
		NUMBER_OF_TYPES
	};
	
	// Type of monster present
	pid_monster_type Type;
	
	// How often they reappear
	short Frequency;
};


// Wall-texture object
// 2 bytes
struct PID_Wall {
	
	// The types:
	enum pid_wall_type: byte {
		None=0,						// Nothing rendered (both wall and corner)
		SwitchableWallCorner=1,		// Corner: everywhere in "The Labyrinth"
		Wall=32,					// Full-length wall
		Wall_FancyCorners=33,		// Full-length wall with fancy corners
		Wall_ShortLow=64,			// Wall that is short on -x/-y end
		Wall_ShortHigh=96,			// Wall that is short on +x/+y end
		Wall_ShortBoth=128,			// Wall that is short on both ends
		CutoffCorner=160			// Corner with short diagonal wall nearby
	};
	// Note: the ends of the shortened walls and the cutoff corners must be able to coincide
	
	// Type of wall
	pid_wall_type Type;
	
	// Texture ID?
	byte Texture;
};


// 16 bytes
struct PID_Sector {

	// The sector types:
	enum pid_sector_type: byte {
		Void,				// Inaccessible
		Normal,				// Accessible, but nothing special
		Door,				// (self-explanatory)
		ChangeLevel,		// Change levels here
		DoorTrigger,		// Triggers doors opening/closing
		SecretDoor,			// What triggers them?
		Corpse,				// You can talk to these
		Pillar,				// Pillar in the middle -- can't walk through
		OtherTrigger,		// Not exactly sure what this one does
		Save,				// Can save game here
		NUMBER_OF_TYPES,
		pid_sector_type_none = -1
	};
	
	// The various kinds of door triggers
	// I don't know what some of them do
	enum {
		Chain1=6,					// Chain to pull in "Never Stop Firing"
		Chain2=7,					// Chain to pull in "Never Stop Firing"
		Unknown_HHCC_1=12,			// In "Happy Happy Carnage Carnage"
		Unknown_HHCC_2=13,			// In "Happy Happy Carnage Carnage"
		CloseNgbrDoor_Flag=14,		// Closes neighboring door unless some flag is set
		Unknown_HHCC_3=17,			// In "Happy Happy Carnage Carnage"
		EndGame=24,					// Ends the game
		CloseNgbrDoor=128,			// Closes neighboring door
		OpenNgbrDoor=129,			// Opens neighboring door
		AlienPipes=130,				// Play the Alien Pipes here and open nearby doors
		OpenNgbrDoor_Silver=131,	// Need silver key to open neighboring door
		OpenNgbrDoor_Gold=132,		// Need gold key to open neighboring door
		Unknown_NAL_1=134,			// In "Need a Light?"
		Unknown_NAL_2=135,			// In "Need a Light?"
		Unknown_WYS=136,			// In "Watch Your Step"
		Unknown_LOS_1=137,			// In "Lasciate Ogni Speranza...", WYS, etc.
		Unknown_LOS_2=138,			// In "Lasciate Ogni Speranza...", WYS, etc.
		Unknown_LOS_3=139,			// In "Lasciate Ogni Speranza...", WYS, etc.
		OpenNgbrDoor_Flag=141		// Opens neighboring door if some flag is set
	};
	
	enum {
		Wall_Y,					// Wall on -Y side of sector
		Wall_X,					// Wall on -X side of sector
		Corner_HighX_LowY,
		Corner_LowX_LowY,
		Corner_HighX_HighY,
		Corner_LowX_HighY,
		NUMBER_OF_WALLS_AND_CORNERS
	};
	
	// The walls and corners
	PID_Wall WallList[NUMBER_OF_WALLS_AND_CORNERS];
	
	// What item ID (-1 is NONE)
	pid_sector_type Item;
	
	// Sector type
	byte Type;
	
	// Extra info for the type
	// Meaning:
	// Type 0 (Void) -- probably ignored
	// Type 1 (Normal) -- probably ignored
	// Type 2 (Door) -- index in list of doors
	// Type 3 (ChangeLevel) -- index in list of level-change dispatches
	// Type 4 (DoorTrigger) -- trigger type
	// Type 5 (SecretDoor) -- direction of opening? (would be the same as for the plain doors)
	// Type 6 (Corpse) -- corpse ID (contiguous from 0)
	// Type 7 (Pillar) -- probably ignored
	// Type 8 (OtherTrigger) -- always zero
	// Type 9 (Save) -- always zero
	byte TypeAddl;
};


// Position of something in the map

// A PID world unit
const long PID_WorldUnitBits = 10;
const long PID_WorldUnit = 1 << PID_WorldUnitBits;

struct PID_Position {
	long x;
	long y;
};

// Full circle of angle:
const long PID_FullCircleBits = 9;
const long PID_FullCircle = 1 << PID_FullCircleBits;

// The angle is 0d for +x, 90d for +y, 180d for -x, and 270d for -y
// 0x00, 0x80, 0x100, and 0x180 in these units (0, 128, 256, 384).


// Map overall geometry
// In map view, map sectors are in rows left to right,
// which are in turn, arranged from top to bottom.

// The textures seem to come in three themes:
// Irregular stone, plain pillar/ladder
// Triangular stone, crystal pillar/ladder
// Rectangular stone, vine pillar/ladder

// 16834 bytes total, 450 bytes in header
struct PID_Level {

	enum {
		// How many sectors in each direction
		NUMBER_X_SECTORS = 32,			// Scanline direction (rightward)
		NUMBER_Y_SECTORS = 32,			// Scanline to scanline (downward)
		TOTAL_NUMBER_OF_SECTORS = 1024,	// Product of the previous two
		
		// Various additional constants
		NAME_LENGTH = 128,
		NUMBER_OF_TEXTURES = 8,
		NUMBER_OF_DOORS = 15,
		NUMBER_OF_LEVELCHANGES = 20,
		NUMBER_OF_MONSTER_TYPES_PRESENT = 3
	};

	// In Pascal format: # bytes + character bytes
	byte Name[NAME_LENGTH];
	
	// The number of the level in sequence
	long LevelNumber;
	
	// The height of the level * 10
	short Height10;
	
	// Possibly player-start position; apparently unused
	PID_Position Start;
	
	// The texture descriptors;
	// These have format:
	// Upper 4 bits: texture variation (0, 1, 2, 3 seen)
	// Lower 12 bits: texture set
	// -1 means no texture.
	// The first one is for walls;
	// the others are likely for floors, ceilings, ladders, pillars, and scenery
	short TextureList[NUMBER_OF_TEXTURES];
	
	// The door descriptors
	PID_Door DoorList[NUMBER_OF_DOORS];
	
	// The level-change dispatches
	PID_LevelChange LevelChangeList[NUMBER_OF_LEVELCHANGES];
	
	// The types of monsters in a level
	PID_Monster MonsterList[NUMBER_OF_MONSTER_TYPES_PRESENT];
	
	// Last, but not least...
	PID_Sector SectorList[TOTAL_NUMBER_OF_SECTORS];
};


// The upcoming objects are player-state and level-state ones;
// their initial values are in the PID app's 'dpin' resource as
// [player state] (number of levels)[level state]
// Their current state is stored in the savegame file, which is all data fork.
// The savegame file has room for 10 saved games, and its format is:
// (Number of savegames) of 128-byte Pascal strings, first byte is length)
// (Number of savegames) of (number of levels) shorts; each one of which points to a
//    level-state object later in the file [0 is the first, 1 is the second, ...]
// (Number of savegames) of player-state objects
// Level-state objects; the initial ones are 0 to ((number of levels) - 1); modified ones
//    follow.


const int PID_NumSavegameSlots = 10;


// Item possesed by player: 8 bytes
struct PID_PlayerItem {
	short Type;				// What kind of item is it?
	short Activity;			// O if inactive, 1 if active, 2 if opened up in inventory view
	short Quantity;			// Number of rounds of ammo or whatever in this item
	short ContainedItem;	// Item contained inside
};


// Weapon performance
// The weapons are, in order:
// Survival knife
// Colt .45 Pistol
// Walther P4 Pistol
// MP-41 Submachine Gun
// M-16 Rifle
// AK-47 Assault Rifle
// M-79 Grenade Launcher
//
// The proficiency levels are, in order:
// (weapon not listed)
// Beginner
// Novice
// Expert
//
struct PID_WeaponPerform {
	short NumKilled;		// How many monsters killed with this weapon
	short Proficiency;		// Proficiency level (0 to 3)
	short Unknown;			// Always seems to be 0
};

// Player state: 2876 bytes
struct PID_PlayerState {
	
	// The total and usable numbers of weapons are different because some (Colt .45 and M-16)
	// are not usable in PID. Here are the usable ones, in order:
	// Survival knife
	// Walther P4 Pistol
	// MP-41 Submachine Gun
	// AK-47 Assault Rifle
	// M-79 Grenade Launcher
	enum {
		TOTAL_WEAPON_TYPES = 7,
		USABLE_WEAPON_TYPES = 5
	};

	long Unknown1;			// A magic number? A random-number seed?
	short Index;			// Which savegame slot
	long Time;				// Amount of game time elapsed in units of 1/60 second
	short Points;			// One's score in the game
	long Treasure;			// How much found, in 100's of dollars
	short Unknown2[32];
	short Handedness;		// 0 = right-handed, 1 = left-handed
	short Unknown3;
	short Level;			// Which one
	PID_Position Pos;		// Position in level
	short Angle;			// Orientation angle
	short Health;			// Displayed value * 10
	short MaxHealth;		// Displayed value * 10
	PID_WeaponPerform WeapPerf[TOTAL_WEAPON_TYPES];
	short Unknown4[22];
	long Damage;			// How much taken; in health units
	short Unknown4a[2];
	long ShotsFired[USABLE_WEAPON_TYPES];
	long ShotsHit[USABLE_WEAPON_TYPES];
	long BodyCount[PID_Monster::NUMBER_OF_TYPES];
	short Unknown4b[2];
	short VisionMode;		// 1 = normal, 257 = wearing IR goggles
	short Flashlight;		// 1 = on, 0 = off
	short Unknown4c[4];
	short PoisonRate;		// ?
	short Unknown4d[41];
	short CrystalInHand;	// Item in list
	short CrystalCharge;
	short Unknown5;
	short WeaponInHand;		// Item in list
	short Unknown6[209];
	
	// All the items currently possessed by the player
	PID_PlayerItem Items[256];
};


// Monster features
struct PID_MonsterState {
	short Type;			// What type of monster?
	short Health;		// How much left?
	short Unused;		// Always zero
	short ItemID;		// In the item list
};


// Assignments of pickup items to the item list
struct PID_PickupAssign {
	short ItemID;		// In the item list
	short PickupID;		// Where in the list of items to be picked up
};


// Items, here, are rather generalized; "inhabitants" might be a better word.
struct PID_ItemState {
	// Position
	PID_Position Pos;
	// Bits are numbered 0 to 15 from right to left.
	// Bit 15 is always 1
	// Bits 7-14 are the shape resource ID
	// Bits 0-6 are for which scenery shape to use;
	// too-high values may wrap around the list and specify an upside-down object (?)
	unsigned short Texture;
	// Not sure what these do
	unsigned short Flags;
	// Always zero
	short Unused;
	// Index to the next item might be present
	// (debris near pillars, stuff at corpses, ejected projectiles?); -1 is none; -2 is ?
	short NextItem;
};


// Level state: 9112 bytes
struct PID_LevelState {

	// How many of each:
	enum {
		MAXIMUM_NUMBER_OF_MONSTERS = 60,
		MAXIMUM_NUMBER_OF_ASSIGNS = 30,
		MAXIMUM_NUMBER_OF_PICKUPS = 40,
		MAXIMUM_NUMBER_OF_ITEMS = 500
	};

	// All the monsters in a level
	short NumMonsters;
	PID_MonsterState MonsterList[MAXIMUM_NUMBER_OF_MONSTERS];
	
	// Assignments of pickup items to item ID's
	short NumAssigns;
	PID_PickupAssign AssignList[MAXIMUM_NUMBER_OF_ASSIGNS];
	
	// Stuff that can be picked up
	PID_PlayerItem PickupList[MAXIMUM_NUMBER_OF_PICKUPS];
	
	// Always either 0 or 1024
	long Unknown1[15];
	
	// Referenced from PID_Sector::Item and PID_ItemState::NextItem, among thers;
	// the unused ones are all zeros except for NextItem, which is -2.
	PID_ItemState Items[MAXIMUM_NUMBER_OF_ITEMS];
	
	// Already-seen parts? 
	long Unknown2[32];
};


// Return to default alignment
#pragma pack(pop)

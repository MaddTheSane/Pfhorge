// This include file defines a base class for doing index sorting
// The methods to be subclassed are Sort (for doing the sorting) and Compare (for
// doing the comparing).
// It is intended to do several passes with the same size of data set;
// simply reset the index list before another sort
// No memory-allocation checks are done here

#pragma once

class IndexSort {
	// Hide this stuff away
	int Size;
	int *IndexList;

public:
	// Constructor: give the number of items to sort
	inline IndexSort(int _Size) {
		Size = _Size;
		if (Size <= 0) Size = 1; // Idiot-proofing
		IndexList = new int[Size];
		ResetIndexList();
	}
	virtual ~IndexSort() {
		delete []IndexList;
	}
	
	// What's the size?
	int GetSize() {return Size;}
	
	// Reset the index list if one wants to do another sort
	inline void ResetIndexList() {
		for (int i=0; i<Size; i++)
			Index(i) = i;
	}
	
	// Index value: returns the index of the item with position Loc in sorted order
	int &Index(int Loc) {return IndexList[Loc];}

	// Comparison function: subclass to return 1 if items i1 and i2 are in proper order,
	// O otherwise. For example, proper order may mean that item 1 is less than item 2.
	virtual int Compare(int i1, int i2) = 0;
	
	// Do the sorting! Subclass for each sort method supported.
	virtual void Sort() = 0;
};

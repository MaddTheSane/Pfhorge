// This does an indexed heap sort, a relatively high-performance sorting algorithm

#pragma once

#include "IndexSort.h"


class IndexHeapSort : public IndexSort {

public:
	// Constructor:
	// Argument: number of elements to sort (need to know how many in advance)
	IndexHeapSort (int _Size) : IndexSort(_Size) {}

	// Destructor:
	~IndexHeapSort() {}
	
	// Do the sorting:
	void Sort();
};

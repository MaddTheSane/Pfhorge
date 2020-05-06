// This program implements an Indexed Heap Sort.

#include "IndexHeapSort.h"


// Sort routine:
void IndexHeapSort::Sort() {

	if (GetSize() < 2) return;
	int Left = GetSize() >> 1;
	int Right = GetSize() - 1;
	int RIndx;
	
	for (;;) {
		if (Left > 0) {
			RIndx = Index(--Left);
		} else {
			RIndx = Index(Right);
			Index(Right) = Index(0);
			if (--Right == 0) {
				Index(0) = RIndx;
				break;
			}
		}
		int Ind1 = Left;
		int Ind2 = ((Left + 1) << 1) - 1;
		while (Ind2 <= Right) {
			if ((Ind2 < Right) && !Compare(Index(Ind2+1),Index(Ind2))) Ind2++;
			if (!Compare(Index(Ind2),RIndx)) {
				Index(Ind1) = Index(Ind2);
				Ind1 = Ind2;
				Ind2 = ((Ind2 + 1) << 1) - 1;
			} else Ind2 = Right + 1;
		}
		Index(Ind1) = RIndx;
	}
}
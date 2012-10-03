
#ifndef RECASTSAMPLESOLOMESH_H
#define RECASTSAMPLESOLOMESH_H

#include "DetourNavMesh.h"
#include "Recast.h"
#include "AS3_rcContext.h"
#include "Sample.h"


class SoloMesh : public Sample
{
protected:

	bool m_keepInterResults;
	float m_totalBuildTimeMs;

	unsigned char* m_triareas;
	rcHeightfield* m_solid;
	rcCompactHeightfield* m_chf;
	rcContourSet* m_cset;
	rcPolyMesh* m_pmesh;
	rcConfig m_cfg;	
	rcPolyMeshDetail* m_dmesh;
	
	void cleanup();
		
public:
	SoloMesh();
	virtual ~SoloMesh();
	
	virtual void handleMeshChanged(class InputGeom* geom);
	virtual bool handleBuild();
};


#endif // RECASTSAMPLESOLOMESHSIMPLE_H
include Makefile.common

CC="$(FLASCC)/usr/bin/g++" -O4
CFLAGS=-O4
#OUTPUT_SWC=recast.swc
OUTPUT_SWC=-emit-swc=recast.navigation -o recast.swc
OUTPUT_OBJ=./obj

DETOUR_OBJS=${OUTPUT_OBJ}/DetourAlloc.o  ${OUTPUT_OBJ}/DetourCommon.o  ${OUTPUT_OBJ}/DetourNavMesh.o  ${OUTPUT_OBJ}/DetourNavMeshBuilder.o  ${OUTPUT_OBJ}/DetourNavMeshQuery.o  ${OUTPUT_OBJ}/DetourNode.o
DETOUR_CROWD_OBJS=${OUTPUT_OBJ}/DetourCrowd.o  ${OUTPUT_OBJ}/DetourLocalBoundary.o  ${OUTPUT_OBJ}/DetourObstacleAvoidance.o  ${OUTPUT_OBJ}/DetourPathCorridor.o  ${OUTPUT_OBJ}/DetourPathQueue.o  ${OUTPUT_OBJ}/DetourProximityGrid.o
DETOUR_TILE_OBJS=${OUTPUT_OBJ}/DetourTileCache.o  ${OUTPUT_OBJ}/DetourTileCacheBuilder.o
RECAST_OBJS=${OUTPUT_OBJ}/Recast.o  ${OUTPUT_OBJ}/RecastAlloc.o  ${OUTPUT_OBJ}/RecastArea.o  ${OUTPUT_OBJ}/RecastContour.o  ${OUTPUT_OBJ}/RecastFilter.o  ${OUTPUT_OBJ}/RecastLayers.o  ${OUTPUT_OBJ}/RecastMesh.o  ${OUTPUT_OBJ}/RecastMeshDetail.o  ${OUTPUT_OBJ}/RecastRasterization.o  ${OUTPUT_OBJ}/RecastRegion.o
DEBUG_DRAW_OBJS=${OUTPUT_OBJ}/DebugDraw.o ${OUTPUT_OBJ}/DetourDebugDraw.o ${OUTPUT_OBJ}/RecastDebugDraw.o ${OUTPUT_OBJ}/RecastDump.o
RECAST_DEMO_OBJS=${OUTPUT_OBJ}/ChunkyTriMesh.o ${OUTPUT_OBJ}/MeshLoaderObj.o ${OUTPUT_OBJ}/InputGeom.o ${OUTPUT_OBJ}/SoloMesh.o ${OUTPUT_OBJ}/Sample.o ${OUTPUT_OBJ}/fastlz.o ${OUTPUT_OBJ}/Sample_TempObstacles.o

ALL_OBJS=${DETOUR_OBJS} ${DETOUR_CROWD_OBJS} ${DETOUR_TILE_OBJS} ${RECAST_OBJS} ${DEBUG_DRAW_OBJS} ${RECAST_DEMO_OBJS}

RECAST_INC=-I../recastnavigation/Recast/Include
DETOUR_INC=-I../recastnavigation/Detour/Include -I../recastnavigation/DetourCrowd/Include -I../recastnavigation/DetourTileCache/Include
DEBUG_INC=-I../recastnavigation/DebugUtils/Include
#DEMO_INC=-I../RecastDemo/Include
DEMO_INC=-I./demo
ALL_INCS=${RECAST_INC} ${DETOUR_INC} ${DEBUG_INC} ${DEMO_INC}

RECAST_SOURCE=../recastnavigation/Recast/Source
#RECAST_DEMO_SOURCE=../RecastDemo/Source
RECAST_DEMO_SOURCE=./demo
DETOUR_SOURCE=../recastnavigation/Detour/Source
DETOUR_CROWD_SOURCE=../recastnavigation/DetourCrowd/Source
DETOUR_TC_SOURCE=../recastnavigation/DetourTileCache/Source
DEBUG_SOURCE=../recastnavigation/DebugUtils/Source


all: recompile


recompile: Detour DetourCrowd DetourTileCache Recast RecastDemo debug

	#cd build && PATH="$(call unixpath,$(FLASCC)/usr/bin):$(PATH)" make -j8

	make swig


debug: DebugDraw 

DebugDraw:
	${CC} -Wall -c ${DEBUG_INC} -o ${OUTPUT_OBJ}/DebugDraw.o ${DEBUG_SOURCE}/DebugDraw.cpp 
	${CC} -Wall -c ${DEBUG_INC} ${RECAST_INC} ${DETOUR_INC}  ${DEBUG_SOURCE}/DetourDebugDraw.cpp -o ${OUTPUT_OBJ}/DetourDebugDraw.o
	${CC} -Wall -c ${DEBUG_INC} ${RECAST_INC} ${DEBUG_SOURCE}/RecastDebugDraw.cpp -o ${OUTPUT_OBJ}/RecastDebugDraw.o
	${CC} -Wall -c ${DEBUG_INC} ${RECAST_INC} ${DEBUG_SOURCE}/RecastDump.cpp -o ${OUTPUT_OBJ}/RecastDump.o

Detour:
	${CC} -Wall -c ${DETOUR_INC} -o ${OUTPUT_OBJ}/DetourAlloc.o ${DETOUR_SOURCE}/DetourAlloc.cpp 
	${CC} -Wall -c ${DETOUR_INC} -o ${OUTPUT_OBJ}/DetourCommon.o ${DETOUR_SOURCE}/DetourCommon.cpp 
	${CC} -Wall -c ${DETOUR_INC} -o ${OUTPUT_OBJ}/DetourNavMesh.o ${DETOUR_SOURCE}/DetourNavMesh.cpp 
	${CC} -Wall -c ${DETOUR_INC} -o ${OUTPUT_OBJ}/DetourNavMeshBuilder.o ${DETOUR_SOURCE}/DetourNavMeshBuilder.cpp 
	${CC} -Wall -c ${DETOUR_INC} -o ${OUTPUT_OBJ}/DetourNavMeshQuery.o ${DETOUR_SOURCE}/DetourNavMeshQuery.cpp 
	${CC} -Wall -c ${DETOUR_INC} -o ${OUTPUT_OBJ}/DetourNode.o ${DETOUR_SOURCE}/DetourNode.cpp 

DetourCrowd:
	${CC} -Wall -c ${DETOUR_INC} -o ${OUTPUT_OBJ}/DetourCrowd.o ${DETOUR_CROWD_SOURCE}/DetourCrowd.cpp
	${CC} -Wall -c ${DETOUR_INC} -o ${OUTPUT_OBJ}/DetourLocalBoundary.o ${DETOUR_CROWD_SOURCE}/DetourLocalBoundary.cpp
	${CC} -Wall -c ${DETOUR_INC} -o ${OUTPUT_OBJ}/DetourObstacleAvoidance.o ${DETOUR_CROWD_SOURCE}/DetourObstacleAvoidance.cpp
	${CC} -Wall -c ${DETOUR_INC} -o ${OUTPUT_OBJ}/DetourPathCorridor.o ${DETOUR_CROWD_SOURCE}/DetourPathCorridor.cpp
	${CC} -Wall -c ${DETOUR_INC} -o ${OUTPUT_OBJ}/DetourPathQueue.o ${DETOUR_CROWD_SOURCE}/DetourPathQueue.cpp
	${CC} -Wall -c ${DETOUR_INC} -o ${OUTPUT_OBJ}/DetourProximityGrid.o ${DETOUR_CROWD_SOURCE}/DetourProximityGrid.cpp

DetourTileCache:
	${CC} -Wall -c ${DETOUR_INC} -o ${OUTPUT_OBJ}/DetourTileCache.o ${DETOUR_TC_SOURCE}/DetourTileCache.cpp
	${CC} -Wall -c ${DETOUR_INC} -o ${OUTPUT_OBJ}/DetourTileCacheBuilder.o ${DETOUR_TC_SOURCE}/DetourTileCacheBuilder.cpp

Recast: 
	${CC} -Wall -c ${RECAST_INC} -o ${OUTPUT_OBJ}/Recast.o ${RECAST_SOURCE}/Recast.cpp
	${CC} -Wall -c ${RECAST_INC} -o ${OUTPUT_OBJ}/RecastAlloc.o ${RECAST_SOURCE}/RecastAlloc.cpp
	${CC} -Wall -c ${RECAST_INC} -o ${OUTPUT_OBJ}/RecastArea.o ${RECAST_SOURCE}/RecastArea.cpp
	${CC} -Wall -c ${RECAST_INC} -o ${OUTPUT_OBJ}/RecastContour.o ${RECAST_SOURCE}/RecastContour.cpp
	${CC} -Wall -c ${RECAST_INC} -o ${OUTPUT_OBJ}/RecastFilter.o ${RECAST_SOURCE}/RecastFilter.cpp
	${CC} -Wall -c ${RECAST_INC} -o ${OUTPUT_OBJ}/RecastLayers.o ${RECAST_SOURCE}/RecastLayers.cpp
	${CC} -Wall -c ${RECAST_INC} -o ${OUTPUT_OBJ}/RecastMesh.o ${RECAST_SOURCE}/RecastMesh.cpp
	${CC} -Wall -c ${RECAST_INC} -o ${OUTPUT_OBJ}/RecastMeshDetail.o ${RECAST_SOURCE}/RecastMeshDetail.cpp
	${CC} -Wall -c ${RECAST_INC} -o ${OUTPUT_OBJ}/RecastRasterization.o ${RECAST_SOURCE}/RecastRasterization.cpp
	${CC} -Wall -c ${RECAST_INC} -o ${OUTPUT_OBJ}/RecastRegion.o ${RECAST_SOURCE}/RecastRegion.cpp

RecastDemo:
	${CC} -Wall -c ${RECAST_INC} ${DEMO_INC} -o ${OUTPUT_OBJ}/ChunkyTriMesh.o ${RECAST_DEMO_SOURCE}/ChunkyTriMesh.cpp
	${CC} -Wall -c ${RECAST_INC} ${DEMO_INC} -o ${OUTPUT_OBJ}/MeshLoaderObj.o ${RECAST_DEMO_SOURCE}/MeshLoaderObj.cpp
	${CC} -Wall -c ${ALL_INCS} -o ${OUTPUT_OBJ}/InputGeom.o ${RECAST_DEMO_SOURCE}/InputGeom.cpp
	${CC} -Wall -c ${ALL_INCS} -o ${OUTPUT_OBJ}/Sample.o ${RECAST_DEMO_SOURCE}/Sample.cpp
	${CC} -Wall -c ${ALL_INCS} -o ${OUTPUT_OBJ}/SoloMesh.o ${RECAST_DEMO_SOURCE}/SoloMesh.cpp
	"$(FLASCC)/usr/bin/gcc" -Wall -c -o ${OUTPUT_OBJ}/fastlz.o ${RECAST_DEMO_SOURCE}/fastlz.c
	${CC} -Wall -c ${ALL_INCS} -o ${OUTPUT_OBJ}/Sample_TempObstacles.o ${RECAST_DEMO_SOURCE}/Sample_TempObstacles.cpp
	
#${CC} -Wall -c ${ALL_INCS} ${RECAST_DEMO_SOURCE}/Sample_SoloMesh.cpp


clean:
	rm ./obj/*.o

swig:
	
	#swig from recast.i file
	# Generate the SWIG wrappers
	PATH="$(call unixpath,$(FLASCC)/usr/bin):$(PATH)" swig -as3 -package org.recastnavigation -c++ -DBT_USE_DOUBLE_PRECISION $(ALL_INCS) -module Recast recast.i &> build/swig.log
	mv Recast_wrap.cxx build
	mv Recast.as build
	
	# Compile the SWIG AS3 wrappers
	java -jar $(call nativepath,$(FLASCC)/usr/lib/asc2.jar) -import $(call nativepath,$(FLASCC)/usr/lib/builtin.abc) -import $(call nativepath,$(FLASCC)/usr/lib/playerglobal.abc) build/Recast.as

	# Compile the SWIG C++ wrappers
	PATH="$(call unixpath,$(FLASCC)/usr/bin):$(PATH)" g++ $(BASE_CFLAGS) $(CFLAGS) -DBT_USE_DOUBLE_PRECISION $(ALL_INCS) build/Recast_wrap.cxx -c &> build/swig_wrapper.log
	mv Recast_wrap.o build

	# protect the required symbols in the LTO exports file
	#cp -f exports.txt build/
	#chmod u+rw build/exports.txt
	#PATH="$(call unixpath,$(FLASCC)/usr/bin):$(PATH)" nm build/Recast_wrap.o | grep " T " | awk '{print $$3}' | sed 's/__/_/' >> build/exports.txt

	# Link the final library
	PATH="$(call unixpath,$(FLASCC)/usr/bin):$(PATH)" g++ -jvmopt=-Xmx1G $(BASE_CFLAGS) -DBT_USE_DOUBLE_PRECISION $(ALL_INCS) main.cpp \
	$(ALL_OBJS) ./build/Recast_wrap.o ./build/Recast.abc \
	-Wl,--start-group \
	-Wl,--end-group \
	-emit-swc=org.recastnavigation $(CFLAGS) $(EXTRA_OPTS) -o build/Recast.swc &> build/swc.log #without -flto opion
	#-emit-swc=org.recastnavigation $(CFLAGS) -flto-api=build/exports.txt $(EXTRA_OPTS) -o build/Recast.swc &> build/swc.log #with -flto option


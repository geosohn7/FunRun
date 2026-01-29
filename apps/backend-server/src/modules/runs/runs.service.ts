import { Injectable } from '@nestjs/common';

// What is a Service?
// This is the "Kitchen" where the heavy lifting happens.
// It calculates distance, checks if you are cheating, and saves data.

@Injectable()
export class RunsService {
    // Temporary storage (In a real app, this would be a Database like PostgreSQL)
    private activeRuns = new Map<string, { userId: string; path: Array<[number, number]>; distance: number }>();

    startRun(userId: string) {
        const runId = Math.random().toString(36).substring(7); // Generate random ID
        this.activeRuns.set(runId, { userId, path: [], distance: 0 });
        console.log(`[RunService] User ${userId} started run ${runId}`);
        return { runId, status: 'STARTED' };
    }

    processLocation(runId: string, lat: number, lng: number) {
        const run = this.activeRuns.get(runId);
        if (!run) return { error: 'Run not found' };

        // Simply add the point for now
        // In strict mode, we would calculate distance between the last point and this new point using a Formula (Haversine)
        if (run.path.length > 0) {
            const lastPoint = run.path[run.path.length - 1];
            const dist = this.calculateDistance(lastPoint[0], lastPoint[1], lat, lng);
            run.distance += dist;
        }

        run.path.push([lat, lng]);

        console.log(`[RunService] Run ${runId}: New Point. Total Dist: ${run.distance.toFixed(2)}m`);
        return { status: 'UPDATED', totalDistance: run.distance };
    }

    stopRun(runId: string) {
        const run = this.activeRuns.get(runId);
        if (!run) return { error: 'Run not found' };

        // Save to DB here...
        this.activeRuns.delete(runId);
        return { status: 'ENDED', finalDistance: run.distance, summary: 'Great job!' };
    }

    // Haversine Formula (Simple explanation: Calculates distance "as the crow flies" on a sphere)
    private calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
        const R = 6371e3; // Earth radius in meters
        const phi1 = (lat1 * Math.PI) / 180;
        const phi2 = (lat2 * Math.PI) / 180;
        const deltaPhi = ((lat2 - lat1) * Math.PI) / 180;
        const deltaLambda = ((lon2 - lon1) * Math.PI) / 180;

        const a =
            Math.sin(deltaPhi / 2) * Math.sin(deltaPhi / 2) +
            Math.cos(phi1) * Math.cos(phi2) * Math.sin(deltaLambda / 2) * Math.sin(deltaLambda / 2);
        const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        return R * c; // in meters
    }
}

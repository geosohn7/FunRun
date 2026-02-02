import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Run } from './entities/run.entity';

@Injectable()
export class RunsService {
    constructor(
        @InjectRepository(Run)
        private runRepository: Repository<Run>,
    ) { }

    async startRun(userId: string) {
        const newRun = this.runRepository.create({
            userId,
            path: [],
            distance: 0,
            status: 'ACTIVE',
        });
        const savedRun = await this.runRepository.save(newRun);
        console.log(`[RunService] User ${userId} started run ${savedRun.id}`);
        return { runId: savedRun.id, status: 'STARTED' };
    }

    async processLocation(runId: string, lat: number, lng: number) {
        const run = await this.runRepository.findOne({ where: { id: runId } });
        if (!run) return { error: 'Run not found' };

        if (!run.path) run.path = [];

        // Calculate distance if there are previous points
        if (run.path.length > 0) {
            const lastPoint = run.path[run.path.length - 1];
            const dist = this.calculateDistance(lastPoint.latitude, lastPoint.longitude, lat, lng);
            run.distance += dist;
        }

        run.path.push({ latitude: lat, longitude: lng, timestamp: Date.now() });

        await this.runRepository.save(run);

        console.log(`[RunService] Run ${runId}: New Point. Total Dist: ${run.distance.toFixed(2)}m`);
        return { status: 'UPDATED', totalDistance: run.distance };
    }

    async stopRun(runId: string) {
        const run = await this.runRepository.findOne({ where: { id: runId } });
        if (!run) return { error: 'Run not found' };

        run.status = 'COMPLETED';
        run.endedAt = new Date();
        await this.runRepository.save(run);

        return { status: 'ENDED', finalDistance: run.distance, summary: 'Great job!' };
    }

    // Haversine Formula
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

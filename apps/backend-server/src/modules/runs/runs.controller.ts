import { Controller, Post, Body, Get, Param } from '@nestjs/common';
import { RunsService } from './runs.service';

// What is a Controller?
// It listens for requests from the mobile app (like a waiter taking orders).
// e.g., POST /runs/start -> "Start a tracking session"

@Controller('runs')
export class RunsController {
    constructor(private readonly runsService: RunsService) { }

    @Post('start')
    async startRun(@Body('userId') userId: string) {
        return await this.runsService.startRun(userId);
    }

    @Post('update')
    async updateRun(
        @Body('runId') runId: string,
        @Body('latitude') lat: number,
        @Body('longitude') lng: number,
    ) {
        return await this.runsService.processLocation(runId, lat, lng);
    }

    @Post('stop')
    async stopRun(@Body('runId') runId: string) {
        return await this.runsService.stopRun(runId);
    }
}

import { Controller, Post, Body, Get, Param } from '@nestjs/common';
import { RunsService } from './runs.service';

// What is a Controller?
// It listens for requests from the mobile app (like a waiter taking orders).
// e.g., POST /runs/start -> "Start a tracking session"

@Controller('runs')
export class RunsController {
    constructor(private readonly runsService: RunsService) { }

    @Post('start')
    startRun(@Body('userId') userId: string) {
        return this.runsService.startRun(userId);
    }

    @Post('update')
    updateRun(
        @Body('runId') runId: string,
        @Body('latitude') lat: number,
        @Body('longitude') lng: number,
    ) {
        return this.runsService.processLocation(runId, lat, lng);
    }

    @Post('stop')
    stopRun(@Body('runId') runId: string) {
        return this.runsService.stopRun(runId);
    }
}

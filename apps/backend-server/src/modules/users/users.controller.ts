import { Controller, Post, Body, Get, Param } from '@nestjs/common';
import { UsersService } from './users.service';

@Controller('users')
export class UsersController {
    constructor(private readonly usersService: UsersService) { }

    @Post('login')
    async login(@Body('nickname') nickname: string) {
        return await this.usersService.createOrLogin(nickname);
    }

    @Get(':id')
    async getUser(@Param('id') id: string) {
        return await this.usersService.getUser(id);
    }
}

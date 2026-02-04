import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';

@Injectable()
export class UsersService {
    constructor(
        @InjectRepository(User)
        private userRepository: Repository<User>,
    ) { }

    async createOrLogin(nickname: string) {
        let user = await this.userRepository.findOne({ where: { nickname } });
        if (!user) {
            user = this.userRepository.create({
                nickname,
                tier: 'BRONZE',
                totalXp: 0,
                totalDistance: 0,
            });
            await this.userRepository.save(user);
        }
        return user;
    }

    async getUser(id: string) {
        return await this.userRepository.findOne({ where: { id } });
    }

    async updateUserStats(userId: string, distanceKm: number) {
        const user = await this.userRepository.findOne({ where: { id: userId } });
        if (!user) return;

        user.totalDistance += distanceKm;

        // Simple XP Logic: 1km = 10 XP
        const xpGained = Math.floor(distanceKm * 10);
        user.totalXp += xpGained;

        // Simple Tier Logic
        if (user.totalXp > 1000) user.tier = 'SILVER';
        if (user.totalXp > 5000) user.tier = 'GOLD';
        if (user.totalXp > 10000) user.tier = 'PLATINUM';

        await this.userRepository.save(user);
    }
}

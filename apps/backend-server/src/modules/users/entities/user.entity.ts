import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('users')
export class User {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column({ unique: true })
    nickname: string;

    @Column({ default: 'BRONZE' })
    tier: string;

    @Column({ default: 0 })
    totalXp: number;

    @Column({ type: 'float', default: 0 })
    totalDistance: number;

    @CreateDateColumn()
    createdAt: Date;
}

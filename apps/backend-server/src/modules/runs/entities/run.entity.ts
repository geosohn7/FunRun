import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne } from 'typeorm';
import { User } from '../../users/entities/user.entity';

@Entity('runs')
export class Run {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column()
    userId: string;

    @ManyToOne(() => User, { onDelete: 'CASCADE' })
    user: User;

    @Column({ type: 'float', default: 0 })
    distance: number;

    @Column({ type: 'jsonb', nullable: true })
    path: { latitude: number; longitude: number; timestamp: number }[];

    @Column({ default: 'ACTIVE' }) // ACTIVE, COMPLETED, CANCELLED
    status: string;

    @Column({ type: 'timestamp', nullable: true })
    endedAt: Date;

    @CreateDateColumn()
    createdAt: Date;
}

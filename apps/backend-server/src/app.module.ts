import { Module } from '@nestjs/common';
import { RunsModule } from './modules/runs/runs.module';
import { UsersModule } from './modules/users/users.module';

@Module({
  imports: [
    // Future: TypeOrmModule.forRoot(...) for DB connection
    RunsModule,
    UsersModule,
  ],
  controllers: [],
  providers: [],
})
export class AppModule { }

import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { RabbitMQModule } from '@golevelup/nestjs-rabbitmq';

@Module({
  imports: [ 
    RabbitMQModule.forRoot(RabbitMQModule, {
      exchanges: [
        {
          type: 'topic',
          name: 'sub-01' 
        },
        {
          type: 'topic',
          name: 'sub-03' 
        },
      ],
      uri: process.env.RABBITMQ_URLS.split(' '),
    }),
    AppModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}

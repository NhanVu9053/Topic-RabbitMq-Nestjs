import { RabbitSubscribe } from '@golevelup/nestjs-rabbitmq';
import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  @RabbitSubscribe({
    exchange: 'sub-01',
    routingKey: 'sub-01-route',
    queue: 'sub-01-queue',
  })
  public async pubSubHandler(msg: {}) {
    console.log(`[Sub 02]: ${JSON.stringify(msg)}`);
  }

  // @RabbitSubscribe({
  //   exchange: 'sub-01',
  //   routingKey: 'sub-02-route',
  //   queue: 'sub-01-queue',
  // })
  // public async pubSubHandler02(msg: {}) {
  //   console.log(`sub-02-route: ${JSON.stringify(msg)}`);
  // }
}

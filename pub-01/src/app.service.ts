import { AmqpConnection } from '@golevelup/nestjs-rabbitmq';
import { Inject, Injectable } from '@nestjs/common';
import { ClientProxy, RpcException } from '@nestjs/microservices';
import { catchError, lastValueFrom, throwError } from 'rxjs';

@Injectable()
export class AppService {
  constructor(
    private readonly amqpConnection: AmqpConnection,
  ) {
    //
  }

  async send(text: string) {
   const a = await this.amqpConnection.publish('sub-01', 'sub-02-route', { data:text});
    console.log('[SUB-01]', 'sub 01', 'sub-01-route',  JSON.stringify({data:text}) );
    console.log(a);
  }

  async send2(text: string) {
    const a = await this.amqpConnection.publish('sub-03', 'sub-03-route', { data:text});
     console.log('Send 2', 'sub 03', 'sub-03-route',  JSON.stringify({data:text}) );
     console.log(a);
   }

}

import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { MicroserviceOptions, Transport } from '@nestjs/microservices';
require('dotenv').config();

async function bootstrap() {
  const microservice =await NestFactory.createMicroservice(AppModule);
  await microservice.listen();
}
bootstrap();

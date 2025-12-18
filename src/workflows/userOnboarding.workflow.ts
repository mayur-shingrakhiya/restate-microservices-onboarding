import * as restate from "@restatedev/restate-sdk";
import {userRequest, userRequestSchema} from "../schemas/userRequest.schema"
import { z } from "zod";
import { Prisma, PrismaClient } from "@prisma/client";
import { kycService} from "../services/kycService";
const KYC_DELAY_MS = 1 * 60 * 1000;

export type UserRequest = z.infer<typeof userRequestSchema>;

const prisma = new PrismaClient();  

export const useronboardingFlow = restate.workflow({
  name: "useronboarding",
  handlers: {
    run: async (ctx: restate.WorkflowContext, user: userRequest) => {
      // user registration validation
      try {
        const validatedUser = userRequestSchema.parse(user);
        
        // Insert user into DB using Prisma
        try {
          const newUser = await prisma.users.create({
            data: validatedUser,
          });

          // User successfully created - NOW send KYC reminder
          ctx.serviceSendClient(kycService).remindKyc(
            {
              email: newUser.email,
              name: user.firstname
            },
            restate.rpc.sendOpts({
              delay: { milliseconds: KYC_DELAY_MS }
            })
          );
          
          return {
            success: true,
            message: "User registered successfully",
            data: newUser,
          };

        } catch (error) {
          // Database error handling
          if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002') {
            // User already exists
            const duplicateField = error.meta?.target as string[] | undefined;
            const fieldName = duplicateField?.[0] || 'email';
            
            return {
              success: false,
              message: `User with this ${fieldName} already exists`,
              code: 'DUPLICATE_USER'
            };
          }
          
          return {
            success: false,
            message: "Database error",
            errors: error,
          };
        }
        
      } catch (error) {
        // Validation error
        if (error instanceof z.ZodError) {
          const errorResponse = {
            success: false,
            message: "Validation failed",
            errors: error.issues.map(err => ({
              field: err.path.join('.'),
              message: err.message
            }))
          };
          
          console.log("Error Response:", JSON.stringify(errorResponse, null, 2));
          return errorResponse;
        }
        throw error;
      }
    },
  },
});
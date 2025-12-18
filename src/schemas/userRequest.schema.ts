export type userRequest = {
  userId: string;
  firstname: string;
  lastname: string;
  email: string;
  phone:string;
  password:string;
  country:string;
  state:string;
  city:string;
};


import { z } from "zod";

// =====================================================
// Zod Validation Schema
// =====================================================
export const userRequestSchema = z.object({
  firstname: z
    .string()
    .min(2, "First name must be at least 2 characters")
    .max(50, "First name must be less than 50 characters"),

  lastname: z
    .string()
    .min(2, "Last name must be at least 2 characters")
    .max(50, "Last name must be less than 50 characters"),

  email: z
    .string()
    .email("Invalid email format")
    .toLowerCase(),

  phone: z
    .string()
    .regex(/^\+?[1-9]\d{1,14}$/, "Invalid phone number format (use E.164 format)"),

  password: z
    .string()
    .min(8, "Password must be at least 8 characters")
    .regex(/[A-Z]/, "Password must contain at least one uppercase letter")
    .regex(/[a-z]/, "Password must contain at least one lowercase letter")
    .regex(/[0-9]/, "Password must contain at least one number"),

  country: z
    .string()
    .min(2, "Country is required")
    .max(100, "Country name too long"),

  state: z
    .string()
    .min(2, "State is required")
    .max(100, "State name too long"),

  city: z
    .string()
    .min(2, "City is required")
    .max(100, "City name too long"),
});

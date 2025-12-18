// src/index.ts
import * as restate from "@restatedev/restate-sdk";
import { useronboardingFlow } from "./workflows/userOnboarding.workflow";
import { kycService } from "./services/kycService";

restate.serve({
  services: [
    useronboardingFlow,
    kycService,
  ],
  port: 9080,
});
/**
 * The running service version.
 *
 * Cloud Run injects K_REVISION, which identifies the exact revision serving a
 * request and is what a support conversation needs. Locally there is no
 * revision, so the package version stands in.
 */
const PACKAGE_VERSION = '0.1.0';

export const SERVICE_VERSION = process.env.K_REVISION ?? PACKAGE_VERSION;

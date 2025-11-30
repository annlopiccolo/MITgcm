# Submesoscale Parameterization Update (2D y–z Experiments)

**Written by:** Anna Lo Piccolo  
**Last update:** November 2025

This repository contains 2D (y–z) MITgcm experiments developed to implement and test the updated submesoscale parameterization. The work follows the 2025 developments by **Anna Lo Piccolo** and **Baylor Fox-Kemper** at Brown University. The parameterization builds on the overturning streamfunction framework of  
**Fox-Kemper, Ferrari, Hallberg (2008)**, and introduces a Redi-like component adapted for entrainment and subduction processes.

## Overview of the Parameterization

### **1. Updated Submesoscale Streamfunction**
The submesoscale overturning streamfunction `ψ` is computed in `submeso_calc_psi.F`. Here the This implementation modifies the vertical structure function `μ`, is updated to deepen and reverse sign below mixed-layer depth, H.

### **2. Redi-like Diffusivity**
A Redi component is incorporated into the submesoscale scheme to allow for passive tracers' fluxes along isopycnals.

Finally, a single unified file, `submeso_calc.F`.

## Diagnostics added
he, depth of maximum entrainment below H, is saved as `EntDepth` and added as new diagnostics.

## Work in progress
### **1. Constraint on me**
### **2. Taper on he to not hit the bottom**
### **3. Redi parameterization for submeso**

## ⚠️ Current Issues / Notes

### **Mixed-Layer Depth, H**
H computed in `calc_oce_mxlayer.F` does not currently represent the depth at which buoyancy fluxes become zero. H is zero at some grids, producing zero overturning. Further adjustments or alternative mixed-layer depth definitions may be required.

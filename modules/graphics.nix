{ pkgs, ... }:

{
  # Intel iGPU (UHD 630 on 8th gen) for hardware video transcoding
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver             # VA-API driver (iHD) for 8th gen and newer
      intel-compute-runtime-legacy1  # OpenCL for HDR tone mapping (Gen 8–11)
    ];
  };
}

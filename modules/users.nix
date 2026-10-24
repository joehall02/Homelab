{ username, ... }:

{
  users.users.${username} = {
    isNormalUser = true;
    description = "Joe Hall";
    extraGroups = [ "networkmanager" "wheel" ];
  };
}

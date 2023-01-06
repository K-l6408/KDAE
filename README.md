# Kschwal's Deltarune Attack Engine
## Attack types
KDAE supports both blue and orange bullets, as well as bullets that can react when shot, blocked or parried (see SOUL modes).
To make them work properly, you have to add a variable called `atkType` in that bullet's script.
I also added some useful constants to help with that, stored in the `Atk` class. For example, the following line of code sets up a blue attack that reacts when shot or parried:
```
var atkType = Atk.Blue & Atk.Shoot & Atk.Parry
```
To edit the behavior of a bullet when shot, blocked or parried you can use the `Shoot()`, `Block()` and `Parry()` functions.
## SOUL modes
Other than the 5 SOUL modes present in Undertale and Deltarune, KDAE includes an orange SOUL mode, where it is forced to always move and can dash through stuff by pressing `Z` (or any other input, specified in the `dash` Input Action).
To make physics object able to get dashed through, you'll need to activate only layer number 2, that gets disabled when dashing.
Another new SOUL mode is the cyan one, that slows you down but allows you to parry incoming bullets pressing `X` (or other inputs, see `parry` Input Action).
The third new SOUL mode is mint (turquoise). With this SOUL mode, you can shrink down by pressing `X` (or other inputs, see `shrink` Action), making you faster as well.
ALSO wait I forgor to mention to slow down you can use the `slowdown` Action, and for shooting while yellow you can use the `shoot` Action.
### Additional mechanics
With the blue SOUL mode, you can also double-jump, triple-jump, really do any number of jumps! Also, by setting the Max Jumps property to be negative, you'll be able to jump infinitely! (flappy bird moment)
Additionally, the yellow mode can be set up to shoot in the direction of the mouse cursor!
Also, you can fuse SOUL modes together! (Be careful though, I haven't tried all possible combinations)

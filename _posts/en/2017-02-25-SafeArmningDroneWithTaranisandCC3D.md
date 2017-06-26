---
uid: DroneSafeArmingWithTaranis
title: Drone safe arming with Taranis (OpenTX)
author: fcerbell
layout: post
lang: en
#description:
category: Drone
#categories
tags: CC3D, Taranis, Drone, Multi-copter, Quadcopter
#date: 9999-01-01
published: true
---

Zero throttle and yaw right is the standard for arming a drone. It is fine, but I wanted to add security with a switch, without wasting an extra channel or introducing a
security breach. The idea is to add an easy but improbable step to arm the drone, to change **nothing** to disarm the drone, and to **not add** a security issue during flight.
When I was young(er), I was told that security needs to ne non-invasive to be efficient... This is my solution, maybe not the best one, but better in my opinion to all that I
found on the net.

* TOC
{:toc}

# Prerequisites

You need to have a working drone, with an Open-TX[^1] based radio. I use a Taranis X9D, but it could be a FlySky or a Turnigy. You have to be able to connect the battery to
your drone, to arm it with your radio (Throttle at zero, yaw at right), to fly and to disarm it (throttle at zero, yaw at left).

# Goal

I just want to add a switch in the arming process. OpenTX checks that all the switches are in the back position at boot. So, if my arming switch is at the back, throttle at
zero and yaw at right should not arm, I have first to move the switch to the front and then to arm with my stick. Easy ? Not really, because the solution has to be non
invasive, everything should work normally whatever the switch position is, and whichever the state is (armed or not). The switch should allow or not only arming, without *any*
side effet.

I need a 2 position switch. The usual "throttle cut" (*T cut* on Turnigy, *SF* on Taranis, the 2 position switch at the top left back of the radio) one is a perfect candidate.
It is usually used on planes or on rovers to stop or nearly stop the engine.

# Options

## Using a dedicated channel

I could use a dedicated channel with a complex rule set (custom functions, variabes, and logical switches). But it would waste one of my precious 16 channels. ;) I don't want.
I find this option not clean.

## Throttle override

I could use a custom function to override the throttle channel to -100. I could still arm/disarm but no motor rotation (if not set in the flight controler) But...  Even in
flight, cutting the throttle does not mean crashing with a plane. But with a multi-rotor, the crash is immediate. 

It would introduce a security issue. So, I forgot this throttle cut option.

## Yaw override

I could use a custom function to override the yaw channel to 0 (middle). Thus, no way to arm (and to disarm neither). In flight, if I trigger it, I simply wont be able to
turn, but I should not crash (at least in stablized modes). Well, I have two issues : disarming is impacted, and there is a security risk if switched during a flight,
specially in acro or rate flight modes. I forgot this option too.

## Limiting the yaw weight

This sounds interesting, I can limit the yaw channel weight 95 or not, the channel range would be from -95 to +95. The impact in flight would be minimal (I never push the
sticks to the end), but emergency disarming would be impacted (impossible when the swith is in the secure position). 

I could limit the channel weight to -97.5/+97.5 with an offset at -2.5. It is better, I can still disarm, but the channel neutral would be moved. My drone would constantly
turn on the yaw axis... No way, but the idea is here...

## Custom curve

I could use a custom curve to lock the channel in the range -100/+95, without offset. Then, with a logical switch, I could apply this curve to the yaw mixer only when the
throttle is low. If I activate the security during flight, yaw would not be impacted (throttle is never near 0). As the curve is normal on the left, whichever the switch
position is, I can always execute and emergency disarm. 

Basically, this solution only forbids the lower-right exreme area when activated. Perfect, no impact during flight is switched, no impact on the ground, no impact for
disarming, no impact on any other behavior.

## Logical switches only

The idea is the same as above, without using a powerful curve, but using a simple logical switch combination :

* A first switch to detect if the throttle is low (below -95)

* A second switch to detect if the yaw is at right (over 95)

* A third switch that test is the first and the second switch are activated together with the physical switch.

Then, a custom function can override the yaw to keep it away from the far right end.

Everything still work as if there were no security, you can still use full throttle range, when armed or not, when swith activated or not, you can still use full yaw range,
armed or not, with the switch activated or not. The only exception is that the yaw wont go to the far right if the throttle is at the bottom and the switch activated. During
flight, it would mean stopping the motors and trying to turn (which is anyway impossible), and in any case, it is always possible to achieve an emergency disarm, as it is
never blocked. Near perfect solution, as my OpenTX can not detect the flight controler arming state.

As a bonus, this solution can play a sound when the switch is activated and the throttle is not at the bottom (typically during flight) to warn the user. And another bonus is
that you can add more simple tests in the combination (forbid arm when the selected flight mode is not a stabilized one, for example).

Well, now, it is time to implement.

# The custom function

You can use both OpenTX Companion or the remote control itself to create the custom function. Basically, it overrides the yaw channel with a value that can not arm the flight
controler if the main logical switch is on. On my flight controler, I found that the armin value is circa 60. So, if the logical switch says that the user tries to arm whereas
it is forbidden, the function overrides the Yaw.

The configuration looks like the following screenshot in OpenTX Companion :

![Custom function in Companion][01-CustomFunctionCompanion.png]

And the same, on the radio afer uploading :

![Custom function on the Radio][02-CustomFunctionRadio.png]

# The logical switches

Now, we have to create the logical switch that means "the user is trying to arm, whereas he should not". In my case, it will be L1. The "he should not" is the physical switch
that you chose earlier (SF/Throttle cut in my case). The part "the user is trying to arm" is : Throttle lower than -85 (observed value with my CC3D/Librepilot 15) and Yaw is
more than 50 (in my case). I implemented this using 3 switches, L1,L2 and L3. L1 is the main one depending on the SF position, combined with an AND with the secondlogical
switch testing for the Throttle value, itself ANDed with the third, testing for the Yaw position.

Here is the definition in Companion :

![Logical switches in Companion][03-LogicalSwitchesCompanion.png]

And the result on the radio :

![Logical switches on the radio][04-LogicalSwitchesRadio.png]

You can play with your sticks when displaying this page to see what happens when you move the sticks with or without the security enabled. You can also go to the main page,
then page until seeing the channelbars and play to see which values will be sent to the flight controler.

# Going further

You can add other logical switches, daisy chained to the last one, to check the flight mode or something else. You can also play sound to tell the user that he should remove
the security switch once flying (when it is still active) and to tell him that the security is actived when he tries to arm.

[01-CustomFunctionCompanion.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/01-CustomFunctionCompanion-en.png "Custom function in Companion"
[02-CustomFunctionRadio.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/02-CustomFunctionRadio-en.png "Custom function on the radio"
[03-LogicalSwitchesCompanion.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/03-LogicalSwitchesCompanion-en.png "Logical switches in Companion"
[04-LogicalSwitchesRadio.png]: {{site.url}}{{site.baseurl}}/assets/posts/{{page.uid}}/04-LogicalSwitchesRadio-en.png "Logical switches on the radio"

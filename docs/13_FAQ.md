# FAQ

## Is DebianMOSS a real distro?
Yes, in the sense that it is a real Debian-based live distro project. No, in the sense that it does not replace Debian's core plumbing with a custom kernel/userspace stack.

## Should I use Debian or Arch as the base?
Debian, unless you have a very specific reason not to.

## Is mosspkg the package manager?
No. `apt` is the real system package manager. `mosspkg` is a helper.

## Can I make my own WM?
Yes. That is one of the cleanest things DebianMOSS is set up to let you do.

## Can I replace XFCE entirely?
Yes, but do it carefully and keep one known-good fallback session.

## Should I try to make ncurses look like KDE?
No. If you want a real desktop, use a real desktop stack.

## Can this become a daily-use distro?
Yes, but only if you keep the scope sane:
- stay on Debian
- package your tools properly
- test hardware and hypervisors honestly
- avoid reinventing package management and core desktop plumbing too early

## Why does building on Arch keep being annoying?
Because the distro is Debian-based and the native builder still expects Debian tooling. Build it in Debian, even if your host is Arch.

## What is the smartest next technical step?
Package the MOSS tools properly as `.deb` packages and tighten the live image defaults.

## What is the smartest next product step?
Pick a target:
- live dev distro
- installed coding distro
- custom session playground

Trying to be everything at once is how the project gets muddy.

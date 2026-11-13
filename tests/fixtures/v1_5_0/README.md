Module 1.5.0 as released, kept only so `upgrade.tftest.hcl` can build state the
way 1.5.0 wrote it. Two test-only changes: its provider pin is widened so it runs
on the same provider as 2.x, and `test_outputs.tf` exposes the instance ID.
Do not use this module.

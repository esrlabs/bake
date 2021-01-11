Performance
===========

Eclipse vs. bake
****************

Test Environement
-----------------
=====================       ==============   ================================================================
Test-System                 *CPU:*           Intel Xeon W3520 (4x 2.67 GHz)

                            *RAM:*           4 GB

                            *OS :*           Windows XP

                            *HDD:*           Raid

Test-Application            ~200 projects
---------------------       ---------------------------------------------------------------------------------
Ruby-Version                ruby 1.9.2
---------------------       ---------------------------------------------------------------------------------
Tests-Runs                  30
=====================       ==============   ================================================================

Test Results
------------

=================================       =================================       =====================================
Test                                    Eclipse 3.6.1, CDT 6                    bake
=================================       =================================       =====================================
Build whole workspace                   13:01 min                               7:19 min

Rebuild without clean                   3:05 min                                0:50 min

Clean whole workspace                   0:41 min                                0:08 min

Clean the cleaned workspace             0:35 min                                0:02 min
=================================       =================================       =====================================

.. note::
    For the build `Eclipse` needs additional `300 MB of RAM`, in contrast `bake` takes up `35 MB` of RAM at it's peak.

CMake with Unix makefiles vs. bake
**********************************

Test Environement
-----------------
=====================       ==============   ================================================================
Test-System                 *CPU:*           Intel Xeon W3520 (4x 2.67 GHz)

                            *RAM:*           4 GB

                            *OS :*           Windows XP

                            *HDD:*           Raid

Test-Application            ~100 projects
---------------------       ---------------------------------------------------------------------------------
Ruby-Version                \-
---------------------       ---------------------------------------------------------------------------------
Tests-Runs                  \-
=====================       ==============   ================================================================

Test Results
------------

* Build whole workspace: bake is `~10%` faster
* Build again without clean: bake is `~50%` faster
* Clean whole workspace: bake is `~80%` faster


Performance using different rubies
**********************************

Test Environement
-----------------
=====================       ==============   ================================================================
Test-System                 *CPU:*           Intel Xeon W3520 (4x 2.67 GHz)

                            *RAM:*           4 GB

                            *OS :*           Windows XP

                            *HDD:*           Raid

Test-Application            ~200 projects
---------------------       ---------------------------------------------------------------------------------
Tests-Runs                  30
=====================       ==============   ================================================================

Test Results
------------

=====================   ==================  ==================  ==================  ==================
\                       ruby 1.8.6p398      ruby 1.8.7p352      ruby 1.9.2p180      ruby 1.9.3p0
=====================   ==================  ==================  ==================  ==================
Build whole workspace   13:58 min           8:07 min            7:19 min            7:28 min

Build single file       1,20 sec            1,87 sec            2,38 sec            1,29 sec
=====================   ==================  ==================  ==================  ==================

.. note::
    * ruby 1.8.6 uses only ONE native thread for multiple ruby threads.
    * ruby 1.9.2 for Windows needs very long to startup for complex applications, which is fixed in 1.9.3

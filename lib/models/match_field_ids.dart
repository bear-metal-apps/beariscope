library;

const kSectionAuto = 'auto';
const kSectionTele = 'tele';
const kSectionEndgame = 'endgame';

/// Number of fuel balls scored during auto.
const kAutoFuelScored = 'fuel_scored';

/// Number of fuel balls passed to a partner during auto.
const kAutoFuelPassed = 'fuel_passed';

/// Shooting accuracy percentage (0–10) in auto.
const kAutoFuelAccuracy = 'fuel_accuracy';

/// Whether the robot triggered an A-Stop during auto.
const kAutoAStop = 'a_stop';

/// Whether the robot collided with another robot during auto.
const kAutoCollided = 'collided';

/// Auto L1 climb result: "Successful" | "Attempted" | "Not Attempted".
const kAutoClimbL1 = 'climb_l1';

/// Starting position: "P1" | "P2" | "P3" | "P4" | "P5".
const kAutoStartPositions = 'start_positions';

/// Number of times the robot traveled under the trench during auto.
const kAutoTraveledUnderTrench = 'traveled_under_trench';

/// Number of times the robot traveled over the bump during auto.
const kAutoTraveledOverBump = 'traveled_over_bump';

/// Whether the robot collected from the outpost during auto.
const kAutoCollectFromOutpost = 'collect_from_outpost';

/// Whether the robot collected from the depot during auto.
const kAutoCollectFromDepot = 'collect_from_depot';

/// Whether the robot collected from quadrant 1 during auto.
const kAutoQuadrant1 = 'quadrant_1';

/// Whether the robot collected from quadrant 2 during auto.
const kAutoQuadrant2 = 'quadrant_2';

/// Whether the robot collected from quadrant 3 during auto.
const kAutoQuadrant3 = 'quadrant_3';

/// Whether the robot collected from quadrant 4 during auto.
const kAutoQuadrant4 = 'quadrant_4';

/// Number of fuel balls scored during teleop.
const kTeleFuelScored = 'fuel_scored';

/// Number of fuel balls passed to a partner during teleop.
const kTeleFuelPassed = 'fuel_passed';

/// Number of fuel balls poached from the opponent's hopper.
const kTeleFuelPoached = 'fuel_poached';

/// Shooting accuracy percentage (0–100) in teleop.
const kTeleFuelAccuracy = 'fuel_accuracy';

/// Whether the robot triggered an E-Stop (emergency stop) during teleop.
const kTeleEStop = 'e_stop';

/// Whether the robot lost communications during teleop.
const kTeleLostComms = 'lost_comms';

/// Number of periods where the robot started with a full hopper.
const kTelePeriodStartedWithFullHopper = 'period_started_with_full_hopper';

/// Number of times the robot traveled over the bump during teleop.
const kTeleOverBump = 'over_bump';

/// Number of times the robot traveled under the trench during teleop.
const kTeleUnderTrench = 'under_trench';

/// Balls passed while in the inactive (non-shooter) role.
const kTeleInactivePassing = 'inactive_passing';

/// Time (seconds, out of ~25) spent collecting fuel.
const kTeleCollecting = 'collecting';

/// Qualitative defense rating assigned by scout (int, higher = more defense).
const kTeleDefense = 'defense';

/// Climb level achieved: "L1" | "L2" | "L3" (absent/null = no climb).
const kEndClimb = 'climb';

/// Climb bar position: "Left" | "Center" | "Right".
const kEndClimbLocation = 'climb_location';

/// Whether the robot played defense while on its scoring shift.
const kEndPlayedDefenseOnShift = 'played_defense_on_shift';

/// Whether the robot played defense while off its scoring shift.
const kEndPlayedDefenseOffShift = 'played_defense_off_shift';

/// Number of fouls committed.
const kEndFouls = 'fouls';

/// Free-text match notes entered by the scout.
const kEndNotes = 'notes';

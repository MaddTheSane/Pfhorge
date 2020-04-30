// PhDefs.h
//
// Definitions for various things... :)


enum /* object transfer modes (high-level) */
{
    _xfer_normal, // Yes for Walls
    _xfer_fade_out_to_black, /* reduce ambient light until black, then tint-fade out */
    _xfer_invisibility,
    _xfer_subtle_invisibility,
    _xfer_pulsate, /* only valid for polygons */   // Yes for Walls
    _xfer_wobble, /* only valid for polygons */   // Yes for Walls
    _xfer_fast_wobble, /* only valid for polygons */   // Yes for Walls
    _xfer_static,
    _xfer_50percent_static,
    _xfer_landscape,   // Yes for Walls
    _xfer_smear, /* repeat pixel(0,0) of texture everywhere */
    _xfer_fade_out_static,
    _xfer_pulsating_static,
    _xfer_fold_in, /* appear */
    _xfer_fold_out, /* disappear */
    _xfer_horizontal_slide,   // Yes for Walls
    _xfer_fast_horizontal_slide,   // Yes for Walls
    _xfer_vertical_slide,   // Yes for Walls
    _xfer_fast_vertical_slide,   // Yes for Walls
    _xfer_wander,   // Yes for Walls
    _xfer_fast_wander,   // Yes for Walls
    _xfer_big_landscape,
    NUMBER_OF_TRANSFER_MODES
};



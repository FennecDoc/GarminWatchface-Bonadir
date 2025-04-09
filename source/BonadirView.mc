import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class BonadirView extends WatchUi.WatchFace {

    var face;
    var Snitch;
    var hour_hand;
    var minute_hand;

    private var _font as FontResource?;
    private var _screenShape as ScreenShape;
    private var _screenCenterPoint as Array<Number>?;
    private var _fullScreenRefresh as Boolean;
    private var _offscreenBuffer as BufferedBitmap?;

    function initialize() {
        WatchFace.initialize();
        _screenShape = System.getDeviceSettings().screenShape;
        _fullScreenRefresh = true;
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
        face = WatchUi.loadResource( Rez.Drawables.face );
        Snitch = WatchUi.loadResource( Rez.Drawables.Snitch );
               
        // Load the custom font we use for drawing the 3, 6, 9, and 12 on the watchface.
        _font = WatchUi.loadResource($.Rez.Fonts.id_font_black_diamond) as FontResource;

        _screenCenterPoint = [dc.getWidth() / 2, dc.getHeight() / 2];

        /*var offscreenBufferOptions = {
                :width=>dc.getWidth(),
                :height=>dc.getHeight()
            };

        if (Graphics has :createBufferedBitmap) {
            // get() used to return resource as Graphics.BufferedBitmap
            _offscreenBuffer = Graphics.createBufferedBitmap(offscreenBufferOptions).get() as BufferedBitmap;

            //_dateBuffer = Graphics.createBufferedBitmap(dateBufferOptions).get() as BufferedBitmap;
        } else if (Graphics has :BufferedBitmap) { // If this device supports BufferedBitmap, allocate the buffers we use for drawing
            // Allocate a full screen size buffer with a palette of only 4 colors to draw
            // the background image of the watchface.  This is used to facilitate blanking
            // the second hand during partial updates of the display
            _offscreenBuffer = new Graphics.BufferedBitmap(offscreenBufferOptions);

            // Allocate a buffer tall enough to draw the date into the full width of the
            // screen. This buffer is also used for blanking the second hand. This full
            // color buffer is needed because anti-aliased fonts cannot be drawn into
            // a buffer with a reduced color palette
            //_dateBuffer = new Graphics.BufferedBitmap(dateBufferOptions);
        } else {
            _offscreenBuffer = null;
            //_dateBuffer = null;
        }*/
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        //var targetDc = null;

        // We always want to refresh the full screen when we get a regular onUpdate call.
        /*_fullScreenRefresh = true;
        if (null != _offscreenBuffer) {
            // If we have an offscreen buffer that we are using to draw the background,
            // set the draw context of that buffer as our target.
            targetDc = _offscreenBuffer.getDc();
            targetDc.clearClip();
        } else {
            targetDc = dc;
        }*/
        
        var clockTime = System.getClockTime();

        var hourHandAngle = (((clockTime.hour % 12) * 60) + clockTime.min);
        hourHandAngle = hourHandAngle / (12 * 60.0);
        hourHandAngle = hourHandAngle * Math.PI * 2;
        var minuteHandAngle = (clockTime.min / 60.0) * Math.PI * 2;
        var secondHand = (clockTime.sec / 60.0) * Math.PI * 2;
        View.onUpdate(dc);       
        dc.setColor(0xFFD700, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(generateHandCoordinates(_screenCenterPoint, hourHandAngle, dc.getHeight() / 6, 0, dc.getWidth() / 80));
        dc.fillPolygon(generateHandCoordinates(_screenCenterPoint, minuteHandAngle, dc.getHeight() / 3, 0, dc.getWidth() / 120));
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(generateHandCoordinates(_screenCenterPoint, secondHand, dc.getHeight() / 4, 20, dc.getWidth() / 120));    
        
        var width = dc.getWidth();
        var height = dc.getHeight();

        // Draw the 3, 6, 9, and 12 hour labels.
        var font = _font;
        if (font != null) {
            dc.setColor(0xF0E68C, Graphics.COLOR_TRANSPARENT);
            dc.drawText(width / 2, 2, font, "12", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(width - 2, (height / 2) - 15, font, "3", Graphics.TEXT_JUSTIFY_RIGHT);
            dc.setColor(0xF0E68C, Graphics.COLOR_BLACK);
            dc.drawText(width / 2, height - 30, font, "6", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(2, (height / 2) - 15, font, "9", Graphics.TEXT_JUSTIFY_LEFT);
        }

         // Call the parent onUpdate function to redraw the layout
         

        // Output the offscreen buffers to the main display if required.
        
        //drawBackground(dc);
        
        //_fullScreenRefresh = false;

        // Get and show the current time
        //var clockTime = System.getClockTime();
        //var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
        //var view = View.findDrawableById("TimeLabel") as Text;
        //view.setText(timeString);
        
       
        
        
        //dc.drawBitmap( dc.getWidth()/2-5,dc.getHeight()/2-5, hour_hand );
        //dc.drawBitmap( dc.getWidth()/2-2.5,dc.getHeight()/2-2.5, minute_hand );
        dc.drawBitmap( dc.getWidth()/2-10,dc.getHeight()/2-10, Snitch );
    }

    //! Draw the watch face background
    //! onUpdate uses this method to transfer newly rendered Buffered Bitmaps
    //! to the main display.
    //! onPartialUpdate uses this to blank the second hand from the previous
    //! second before outputting the new one.
    //! @param dc Device context
    private function drawBackground(dc as Dc) as Void {

        // If we have an offscreen buffer that has been written to
        // draw it to the screen.
        if (null != _offscreenBuffer) {
            dc.drawBitmap(0, 0, _offscreenBuffer);
        }
    }

    //! This function is used to generate the coordinates of the 4 corners of the polygon
    //! used to draw a watch hand. The coordinates are generated with specified length,
    //! tail length, and width and rotated around the center point at the provided angle.
    //! 0 degrees is at the 12 o'clock position, and increases in the clockwise direction.
    //! @param centerPoint The center of the clock
    //! @param angle Angle of the hand in radians
    //! @param handLength The length of the hand from the center to point
    //! @param tailLength The length of the tail of the hand
    //! @param width The width of the watch hand
    //! @return The coordinates of the watch hand
    private function generateHandCoordinates(centerPoint as Array<Number>, angle as Float, handLength as Number, tailLength as Number, width as Number) as Array<[Numeric, Numeric]> {
        // Map out the coordinates of the watch hand
        var coords = [[-(width / 2), tailLength],
                      [-(width / 2), -handLength],
                      [width / 2, -handLength],
                      [width / 2, tailLength]];
        var result = new Array<[Numeric, Numeric]>[4];
        var cos = Math.cos(angle);
        var sin = Math.sin(angle);

        // Transform the coordinates
        for (var i = 0; i < 4; i++) {
            var x = (coords[i][0] * cos) - (coords[i][1] * sin) + 0.5;
            var y = (coords[i][0] * sin) + (coords[i][1] * cos) + 0.5;

            result[i] = [centerPoint[0] + x, centerPoint[1] + y];
        }

        return result;
    }

    //! Draws the clock tick marks around the outside edges of the screen.
    //! @param dc Device context
    private function drawHashMarks(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();

        // Draw hashmarks differently depending on screen geometry.
        if (System.SCREEN_SHAPE_ROUND == _screenShape) {
            var outerRad = width / 2;
            var innerRad = outerRad - 10;
            // Loop through each 15 minute block and draw tick marks.
            for (var i = Math.PI / 6; i <= 11 * Math.PI / 6; i += (Math.PI / 3)) {
                // Partially unrolled loop to draw two tickmarks in 15 minute block.
                var sY = outerRad + innerRad * Math.sin(i);
                var eY = outerRad + outerRad * Math.sin(i);
                var sX = outerRad + innerRad * Math.cos(i);
                var eX = outerRad + outerRad * Math.cos(i);
                dc.drawLine(sX, sY, eX, eY);
                i += Math.PI / 6;
                sY = outerRad + innerRad * Math.sin(i);
                eY = outerRad + outerRad * Math.sin(i);
                sX = outerRad + innerRad * Math.cos(i);
                eX = outerRad + outerRad * Math.cos(i);
                dc.drawLine(sX, sY, eX, eY);
            }
        } else {
            var coords = [0, width / 4, (3 * width) / 4, width];
            for (var i = 0; i < coords.size(); i++) {
                var dx = ((width / 2.0) - coords[i]) / (height / 2.0);
                var upperX = coords[i] + (dx * 10);
                // Draw the upper hash marks.
                dc.fillPolygon([[coords[i] - 1, 2],
                                [upperX - 1, 12],
                                [upperX + 1, 12],
                                [coords[i] + 1, 2]]);
                // Draw the lower hash marks.
                dc.fillPolygon([[coords[i] - 1, height - 2],
                                [upperX - 1, height - 12],
                                [upperX + 1, height - 12],
                                [coords[i] + 1, height - 2]]);
            }
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

}

package com.example.shalin.drawingtest;

import android.app.Activity;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.media.MediaPlayer;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.MotionEvent;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import java.util.ArrayList;
import java.util.Random;

public class MainActivity extends Activity {

    // gameView will be the view of the game
    // It will also hold the logic of the game
    // and respond to screen touches as well
    GameView gameView;
    MediaPlayer backPlayer;

    Colour[] colours_Start = {new Colour("RED", 255, 128, 128), new Colour("GREEN", 128, 255, 128), new Colour("BLUE", 128, 128, 255), new Colour("YELLOW", 255, 255, 128), new Colour("PURPLE", 255, 128, 255), new Colour("ORANGE", 255, 191, 128)};

    Colour[] colours_End   = {                                         new Colour("RED",    255,   0,   0),
            new Colour("DARK_GREEN",   0, 128,   0), new Colour("GREEN",    0, 196,   0),       new Colour("LIGHT_GREEN",   0, 255,   0),
            new Colour("DARK_BLUE",    0,   0, 128), new Colour("BLUE",     0,   0, 196),       new Colour("LIGHT_BLUE",    0,   0, 255),
            new Colour("YELLOW", 255, 255,   0),
            new Colour("DARK_PURPLE", 128,  0, 128), new Colour("PURPLE", 196,   0, 196),       new Colour("LIGHT_PURPLE",  255, 0, 255),
            new Colour("ORANGE", 255, 128,   0)};



    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Initialize gameView and set it as the view
        gameView = new GameView(this);
        setContentView(gameView);

        backPlayer = MediaPlayer.create(this, R.raw.backgroundtrack);
    }

    class GameView extends SurfaceView implements Runnable {

        // This is our thread
        Thread gameThread = null;

        // This is new. We need a SurfaceHolder
        // When we use Paint and Canvas in a thread
        // We will see it in action in the draw method soon.
        SurfaceHolder ourHolder;

        // A boolean which we will set and unset
        // when the game is running- or not.
        volatile boolean playing;

        // A Canvas and a Paint object
        Canvas canvas;
        Paint paint;

        Random random;

        // This variable tracks the game frame rate
        long mspf = 1000/30;

        // This is used to help calculate the fps
        long lastTime = 0;
        long time = System.currentTimeMillis();


        //NODEs AND STUFF
        float rad = 60f; //ON SAMSUNG GALAXY TAB 3, it should be at 24

        //Width+height of screen
        int width, height;

        ArrayList<Node> nodes;
        int numNodes;
        //How many source nodes are there
        int numSources;
        Region[][] regions;

        int maxCounter = 50;
        int counter = maxCounter;

        // When the we initialize (call new()) on gameView
        // This special constructor method runs
        public GameView(Context context) {
            // The next line of code asks the
            // SurfaceView class to set up our object.
            // How kind.
            super(context);

            // Initialize ourHolder and paint objects
            ourHolder = getHolder();
            paint = new Paint();

            random = new Random();
            // Set our boolean to true - game on!
            playing = true;

            nodes = new ArrayList<Node>();
            numNodes = 0;
            numSources = 0;


            DisplayMetrics displayMetrics = new DisplayMetrics();
            getWindowManager().getDefaultDisplay().getMetrics(displayMetrics);
            width = displayMetrics.widthPixels - 2 * (int)rad;
            height = displayMetrics.heightPixels - 2 * (int)rad;

            if (height > width) {
                regions = new Region[2][3];
            } else {
                regions = new Region[3][2];
            }

            for (int x = 0; x < regions.length; x++){
                for (int y = 0; y < regions[0].length; y++){
                    regions[x][y] = new Region(
                            width / regions.length * x + rad,
                            height / regions[0].length * y + rad,
                            width / regions.length - 5,
                            height / regions[0].length - 5,
                            255 / 10 * (x + y + 2)
                    );
                }
            }

            width += 2 * rad;
            height += 2 * rad;
        }

        void CreateNode() {
            //Pick a random COLUMN (regions[][THIS ONE])
            //Check one of them randomly
            //If that doesn't work, then try the next row
            if (numSources < regions.length * regions[0].length) {
                int j = random.nextInt(regions[0].length);
                int i = random.nextInt(regions.length);

                if (!regions[i][j].occupied) {
                    numNodes++;
                    numSources++;
                    Node n = new Node(regions[i][j].startX + random.nextInt(regions[i][j].width), regions[i][j].startY + random.nextInt(regions[i][j].height));
                    n.region = regions[i][j];
                    nodes.add(n);
                    regions[i][j].occupied = true;

                } else {
                    int x, y;
                    OUTER:
                    for (int I = 0; I < regions.length; I++) {
                        for (int J = 0; J < regions[0].length; J++) {
                            x = i + I;
                            y = j + J;

                            if (x >= regions.length) {
                                x -= regions.length;
                            }
                            if (y >= regions[0].length) {
                                y -= regions[0].length;
                            }

                            if (!regions[x][y].occupied) {
                                numNodes++;
                                numSources++;
                                Node n = new Node(regions[x][y].startX + random.nextInt(regions[x][y].width), regions[x][y].startY + random.nextInt(regions[x][y].height));
                                n.region = regions[x][y];
                                nodes.add(n);

                                regions[x][y].occupied = true;
                                break OUTER;
                            }
                        }
                    }
                }
            }
        }

        Colour PickStartColour(){
            return (colours_Start[random.nextInt(colours_Start.length)]);
        }
        Colour PickEndColour(){
            return (colours_End[random.nextInt(colours_End.length)]);
        }
        @Override
        public void run() {
            //The game loop
            backPlayer.start();
            backPlayer.setLooping(true);

            while (playing) {
                time = System.currentTimeMillis();

                if (time >= lastTime + mspf) {
                    update();
                    // Draw the frame
                    draw();

                    lastTime = time;
                }
            }
        }

        // Everything that needs to be updated goes in here
        // In later projects we will have dozens (arrays) of objects.
        // We will also do other things like collision detection.

        public void update() {
            for (int i = 0; i < numNodes; i++){
                nodes.get(i).Update();
            }

            if (numNodes <= 0) {
                counter -= 1;
                if (counter <= 0){
                    CreateNode();
                    counter = maxCounter;
                }
            }
        }

        // Draw the newly updated scene
        public void draw() {

            // Make sure our drawing surface is valid or we crash
            if (ourHolder.getSurface().isValid()) {
                // Lock the canvas ready to draw
                canvas = ourHolder.lockCanvas();

                // Draw the background color
                canvas.drawColor(Color.argb(255,  0, 0, 0));

                // Choose the brush color for drawing
                paint.setColor(Color.argb(255,  255, 255, 255));

                // Make the text a bit bigger
                paint.setTextSize(45);

                // Display the current fps on the screen
                //canvas.drawText("FPS:" + fps, 20, 40, paint);

                //canvas.drawCircle(100, 100, 200, paint);
                // Draw everything to the screen

                for (int x = 0; x < regions.length; x++) {
                    for (int y = 0; y < regions[0].length; y++){
                        paint.setColor(Color.argb(255, regions[x][y].colour, regions[x][y].colour, regions[x][y].colour));
                        canvas.drawRect(regions[x][y].startX, regions[x][y].startY, regions[x][y].startX + regions[x][y].width, regions[x][y].startY + regions[x][y].height, paint);
                    }
                }
                for (int i = 0; i < numNodes; i++) {
                    Node n = nodes.get(i);
                    paint.setColor(Color.argb(255, n.r, n.g, n.b));
                    canvas.drawCircle(n.x, n.y, n.radius, paint);
                }
                ourHolder.unlockCanvasAndPost(canvas);
            }
        }

        // If SimpleGameEngine Activity is paused/stopped
        // shutdown our thread.
        public void pause() {
            playing = false;
            backPlayer.pause();
            try {
                gameThread.join();
            } catch (InterruptedException e) {
                Log.e("Error:", "joining thread");
            }

        }

        // If SimpleGameEngine Activity is started then
        // start our thread.
        public void resume() {
            playing = true;
            backPlayer.start();
            gameThread = new Thread(this);
            gameThread.start();
        }

        // The SurfaceView class implements onTouchListener
        // So we can override this method and detect screen touches.
        @Override
        public boolean onTouchEvent(MotionEvent motionEvent) {

            switch (motionEvent.getAction() & MotionEvent.ACTION_MASK) {

                // Player has touched the screen
                case MotionEvent.ACTION_DOWN:
                    float x = motionEvent.getX();
                    float y = motionEvent.getY();
                    for (Node n : nodes){
                        if (!n.active) {
                            if (Math.sqrt((n.x - x) * (n.x - x) + (n.y - y) * (n.y - y)) < 2 * rad) {
                                //sound stuff here if it comes up
                                n.activate();
                                break;
                            }
                        }
                    }
                    break;

                // Player has removed finger from screen
                case MotionEvent.ACTION_UP:
                    break;
            }
            return true;
        }

    }
    // This is the end of our GameView inner class
    // More SimpleGameEngine methods will go here

    // This method executes when the player starts the game
    @Override
    protected void onResume() {
        super.onResume();

        // Tell the gameView resume method to execute
        gameView.resume();
    }

    // This method executes when the player quits the game
    @Override
    protected void onPause() {
        super.onPause();

        // Tell the gameView pause method to execute
        gameView.pause();
    }

    class Node{

        private boolean active;
        private boolean finished;
        private boolean bloom;

        private float x, y;  //Position
        private float radius;  //width of the node
        private float maxRadius;  //How much it will swell when it is clicked (After which it will bloom)
        private float endRadius;  //How much it will shrink when it reaches maxRadius

        private float offset;

        private float duration; //maximum duration 9Seconds (9000 millis)

        private int numBlooms;
        private float angle;
        private float angleIncrease;
        private int bloomDepth;

        public int r, g, b;
        private int rC, gC, bC;


        Region region;

        public Node(float xin, float yin){  //CONSTRUCTOR FOR SOURCE
            active = false;
            finished = false;
            bloom = false;

            x = xin;
            y = yin;
            radius = gameView.rad;
            maxRadius = gameView.rad * 1.5f;
            endRadius = maxRadius;

            offset = (50 + gameView.random.nextInt(125))/100f;//max value 2, min value .75 -> 200/100 & 75/100

            numBlooms = 2 + gameView.random.nextInt(6);
            angle = 360 / (numBlooms);
            angleIncrease = -45 + gameView.random.nextInt(90);

            //bloomDepth = 5 + gameView.random.nextInt(3);     //For Tab 3
            bloomDepth = 8 + gameView.random.nextInt(16);


            //SET COLOURS HERE
            Colour startC = gameView.PickStartColour();
            Colour endC = gameView.PickEndColour();

            r = startC.r;
            g = startC.g;
            b = startC.b;

            rC = (endC.r - startC.r) / bloomDepth;
            gC = (endC.g - startC.g) / bloomDepth;
            bC = (endC.b - startC.b) / bloomDepth;

            duration = 6500f;
        }

        public Node(float xin, float yin, Node parent, float ain) {
            active = true;
            finished = false;
            bloom = true;

            offset = parent.offset;

            x = xin;
            y = yin;
            radius = parent.radius * 4/5 + 2;
            maxRadius = radius;
            endRadius = radius * 7 / 8;
            radius = radius * 5 / 6;


            numBlooms = 1;
            angle = ain;
            angleIncrease = parent.angleIncrease;
            bloomDepth = parent.bloomDepth - 1;

            rC = parent.rC;
            gC = parent.gC;
            bC = parent.bC;

            r = parent.r + rC;
            g = parent.g + gC;
            b = parent.b + bC;

            duration = parent.duration - 100f;
        }

        void Update(){

            if (active) {
                if (!finished) {
                    radius++;
                    if (radius >= maxRadius) {
                        Bloom();
                    }
                }
                else if (radius > endRadius){
                    radius --;
                }
                duration -= gameView.time - gameView.lastTime;

                if (duration <= 0){
                    Die();
                }
            }
        }

        void Bloom() {
            finished = true;
            float angleOffset = 0;
            if (bloomDepth > 0){
                if (!bloom){
                    gameView.CreateNode();
                    angleOffset = -60 + gameView.random.nextInt(120);
                }
                for (int i = 0; i < numBlooms; i++){
                    gameView.numNodes++;
                    gameView.nodes.add(new Node(
                            x + offset * radius * (float)Math.cos(Math.toRadians((i + 1) * angle + angleOffset)),
                            y + offset * radius * (float)Math.sin(Math.toRadians((i + 1) * angle + angleOffset)),
                            this,
                            i * angle + angle + angleIncrease + angleOffset)
                    );
                }
            }

            //If it is off the screen, then delete it early
            //Can't delete it right away or the pattern could be cut off
            if (x < (-2 * radius) || x > (gameView.width + radius)){
                Die();
            } else if (y < (-2 * radius) || y > (gameView.height + radius)){
                Die();
            }
        }

        void Die() {
            if (!bloom){
                region.occupied = false;
                gameView.numSources--;
            }
            gameView.numNodes--;
            gameView.nodes.remove(this);
        }
        void activate(){
            active = true;
        }
    }

    class Region{
        float startX, startY;
        int width, height;

        boolean occupied;

        int colour;

        public Region(float xin, float yin, int win, int hin, int cin){
            startX = xin;
            startY = yin;
            width = win;
            height = hin;
            colour = cin;
        }
    }

    class Colour {
        String name;
        int r, g, b;
        public Colour(String nin, int rin, int gin, int bin){
            name = nin;
            r = rin;
            g = gin;
            b = bin;
        }
    }
}
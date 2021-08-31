<h2>MBC Timer Control Module for Pascal/MT+</h2>
<p>(C) 2021 D. Collins</p>
<p>This module contians routines for using the real time clock module (DS3231) as well as a 555 timer wired to pin 7 and 1 of PORT B of the GPIO for use with the GPIO Games Adapter for tracking 11ms intervals. The Game's adapter uses a spare inverter left over on it's schmidt trigger to invert a high signal for triggering the 555 timer to start.&nbsp; Pin 1 (GPIO B) is used for a expired signal, which is at a high state when running, and dops to low when expired.&nbsp; Pin 7 is used to trigger the 555 timer with a simple high signal.</p>
<p>&nbsp;</p>
<p><strong>Hooking up the games adapter:</strong></p>
<p>The games adapter contains a 555 timer which can be used as a refrence to the passage of 11ms.&nbsp; This can be usefull to writeing games or building delays that are not based on, or do not require nearly as much CPU usage to acomplish (just a few bytes on the bus to refrence the timer status, and augmenting a location in memory by 1).&nbsp; It's very rudimentary but world's better than no on system timer.&nbsp; it has a resolution of 11ms in stock configuration meaning it will run for 11ms and if you carefully code your program to refrence the timer within this window, you can reliably keep track of time without loosing to many cycles to managing time. because it requrires very little IO all that is required is 2 open signals you can read an write to. also has the benifit of being relitively the same timing on a faster or slower CPU.</p>
<pre>MBC Expansion Port <br />GPIO GAME ADDAPTER CONN. <br />UP = U DOWN = D LEFT = l <br />RIGHT = R FIRE = F <br />555 TRIGGER = TRG (HIGH TRIGGERS) <br />555 EXPIRED = EXP (LOW = EXPIRED<br />                   HIGH = RUNNING) <br />PASSIVE BUZZER = SND<br /><br />VCC    F U D L R   GND <br /> |     | | | | |   | <br />+5 1 2 3 4 5 6 7 8 GND <br /> * * * * * * * * * * GPIO PORT A <br /> * * * * * * * * * * GPIO PORT B <br />   |           | | <br /> EXP         TRG SND </pre>
<p><strong>Symbol Definitions:</strong></p>
<p><em>init555Timer &lt;procedure&gt;</em></p>
<p>Sets up GPIO B for the 555 timer, by setting it's IO state required before using the 555 timer on the game adapter.</p>
<p><em>Start555 &lt;procedure&gt; </em></p>
<p>This starts the 555 timer running, by sending a high signal to pin 7. this will not have any effect if the timer is already running.</p>
<p><em>Expired555 &lt;function, Boolean&gt; </em></p>
<p>This checks to see if the timer is expired and returns a true or false state.&nbsp; If it detects a 1 on the pin it returns false (running), and a zero it will return true (ended).</p>
<p><em>delay(ms :integer) &lt;procedure&gt;</em></p>
<p>exicutes a delay with 11ms resolution and a range of 11 - 32756. It uses the 555 timer IC on the game adapter to provide the delay timer. the game adapter must be built to specification with the default passives in order to provide correct timeing on this delay routine.</p>
<p><em>RTCGetSec &lt;Function : Integer&gt;</em></p>
<p>returns the current seconds value from the RTC using a very fast data grab for accuracy, very few cycles.</p>
<p><em>RTCGetTime &lt;procedure&gt;</em></p>
<p>Populates the global variable CurrentTime a byte array 0..6 bytes.&nbsp; The returned values 0..6 are the same as per the MBC2/v20-MBC sectch documentation. it is much slower to return time this way as it has to read the bus 7 times to get all the data. you will need to add time.vdf to your variable decloaration block in your main souce, as well as time.tdf in your type block in order to break out the CurrentTime variable for use.</p>
<p><em>RTCZeroCounter &lt;procedure&gt; </em></p>
<p>Zeros out a seconds counter which can be used to count seconds with RTCCounter.</p>
<p><em>RTCCounter &lt;function :integer&gt;</em></p>
<p>returns the number of seconds passed since the counter was started.&nbsp; It will output 0 if the counter is left to go over 1 hour, this is to keep the math within the type limit for a basic intiger</p>
<p>&nbsp;</p>
<p>MIT License</p>
<p>Copyright (c) 2021 Dave Collins</p>
<p>Permission is hereby granted, free of charge, to any person obtaining a copy<br />of this software and associated documentation files (the "Software"), to deal<br />in the Software without restriction, including without limitation the rights<br />to use, copy, modify, merge, publish, distribute, sublicense, and/or sell<br />copies of the Software, and to permit persons to whom the Software is<br />furnished to do so, subject to the following conditions:</p>
<p>The above copyright notice and this permission notice shall be included in all<br />copies or substantial portions of the Software.</p>
<p>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR<br />IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,<br />FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE<br />AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER<br />LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,<br />OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE<br />SOFTWARE.</p>

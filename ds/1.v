`timescale 1s/1ms

module user_interface_tb;

    // Inputs
    reg clk = 0;
    reg rst = 1;
    reg start_timer = 0;
    reg [5:0] timer_minutes = 0;
    reg [4:0] alarm_hr_set =12;
    reg [5:0] alarm_min_set = 1;
    reg [5:0] alarm_sec_set = 0;

    // Clock outputs
    wire [5:0] sec, min;
    wire [4:0] hr;
    wire is_am, is_pm;
    wire [4:0] day;
    wire [3:0] month;
    wire [6:0] year;
    wire [4:0] display_hr;
    wire [4:0] hr_24;

    // Timer outputs
    wire [5:0] timer_min;
    wire [5:0] timer_sec;
    wire timer_active;
    wire timer_buzzer;

    // Alarm outputs
    wire alarm_buzzer;

    // 1Hz Clock generation
    always #0.5 clk = ~clk;

    // Instantiate clock
    clock_12hr clk12 (
        .clk(clk),
        .rst(rst),
        .sec(sec),
        .min(min),
        .hr(hr),
        .is_am(is_am),
        .is_pm(is_pm),
        .day(day),
        .month(month),
        .year(year),
        .display_hr(display_hr),
        .hr_24(hr_24)
    );

    // Instantiate countdown timer
    countdown_timer timer (
        .clk(clk),
        .rst(rst),
        .start_timer(start_timer),
        .timer_minutes(timer_minutes),
        .timer_min(timer_min),
        .timer_sec(timer_sec),
        .timer_active(timer_active),
        .timer_buzzer(timer_buzzer)
    );

    // Instantiate alarm
    alarm_system alarm (
        .clk(clk),
        .rst(rst),
        .hr(display_hr),
        .min(clk12.min),
        .sec(clk12.sec),
        .alarm_hr(alarm_hr_set),
        .alarm_min(alarm_min_set),
        .alarm_sec(alarm_sec_set),
        .alarm_buzzer(alarm_buzzer)
    );

    // Display output every second
    always @(posedge clk) begin
        $display("-----------------------------------------------------------------");
        $display("TIME     : %02d:%02d:%02d %s (24Hr: %02d:%02d:%02d)",
                 display_hr, min, sec, is_am ? "AM" : "PM", hr_24, min, sec);
        $display("DATE     : %02d/%02d/20%02d", day, month, year);
        $display("ALARM    : Set for %02d:%02d:%02d => [%s]",
                 alarm_hr_set, alarm_min_set, alarm_sec_set,
                 alarm_buzzer ? "BUZZING!" : "OFF");

        if (timer_active)
            $display("TIMER    : %02d:%02d => [%s]", timer_min, timer_sec, timer_buzzer ? "BUZZING!" : "RUNNING");
        else if (timer_buzzer)
            $display("TIMER    : [BUZZING DONE]");
        else
            $display("TIMER    : [IDLE]");
    end

    // Simulation behavior
   initial begin
    rst = 1;
    #1 rst = 0;

    // Set alarm time
    alarm_hr_set = 12;
    alarm_min_set = 14;
    alarm_sec_set = 0;

    // Run long enough to trigger it
    #1000;
    $finish;
end


endmodule

module clock_12hr (
    input wire clk,
    input wire rst,
    output reg [5:0] sec,
    output reg [5:0] min,
    output reg [4:0] hr,           // 0–11
    output reg is_am,
    output reg is_pm,
    output reg [4:0] day,
    output reg [3:0] month,
    output reg [6:0] year,
    output reg [4:0] display_hr,   // 1–12
    output reg [4:0] hr_24
);

    always @(*) begin
        is_pm = ~is_am;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sec     <= 0;
            min     <= 0;
            hr      <= 0;
            is_am   <= 1;
            day     <= 1;
            month   <= 1;
            year    <= 20;
        end else begin
            if (sec == 59) begin
                sec <= 0;
                if (min == 59) begin
                    min <= 0;
                    if (hr == 11) begin
                        hr <= 0;
                        is_am <= ~is_am;
                        if (is_pm) begin
                            if ((month == 2 && day == 28) ||
                                ((month == 4 || month == 6 || month == 9 || month == 11) && day == 30) ||
                                (day == 31)) begin
                                day <= 1;
                                if (month == 12) begin
                                    month <= 1;
                                    year <= (year == 99) ?  : year + 1;
                                end else begin
                                    month <= month + 1;
                                end
                            end else begin
                                day <= day + 1;
                            end
                        end
                    end else begin
                        hr <= hr + 1;
                    end
                end else begin
                    min <= min + 1;
                end
            end else begin
                sec <= sec + 1;
            end
        end
    end

    always @(*) begin
        display_hr = (hr == 0) ? 12 : hr;
    end

    always @(*) begin
        if (is_am)
            hr_24 = (hr == 0) ? 0 : hr;
        else
            hr_24 = (hr == 0) ? 12 : hr + 12;
    end

endmodule

module alarm_system (
    input wire clk,
    input wire rst,
    input wire [4:0] hr,
    input wire [5:0] min,
    input wire [5:0] sec,
    input wire [4:0] alarm_hr,
    input wire [5:0] alarm_min,
    input wire [5:0] alarm_sec,
    output reg alarm_buzzer
);
   always @(posedge clk)
   $display ("%d %d %d",hr,min , sec);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            alarm_buzzer <= 0;
        end else if (hr == alarm_hr && min == alarm_min ) begin
            alarm_buzzer <= 1;
        end else begin
            alarm_buzzer <= 0;
        end
    end

endmodule
module countdown_timer (
    input wire clk,
    input wire rst,
    input wire start_timer,
    input wire [5:0] timer_minutes,

    output reg [5:0] timer_min,
    output reg [5:0] timer_sec,
    output reg timer_active,
    output reg timer_buzzer
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            timer_min <= 0;
            timer_sec <= 0;
            timer_active <= 0;
            timer_buzzer <= 0;
        end else if (start_timer) begin
            timer_min <= timer_minutes;
            timer_sec <= 0;
            timer_active <= 1;
            timer_buzzer <= 0;
        end else if (timer_active) begin
            if (timer_min == 0 && timer_sec == 0) begin
                timer_buzzer <= 1;
                timer_active <= 0;
            end else begin
                if (timer_sec == 0) begin
                    timer_sec <= 59;
                    timer_min <= timer_min - 1;
                end else begin
                    timer_sec <= timer_sec - 1;
                end
            end
        end
    end

endmodule

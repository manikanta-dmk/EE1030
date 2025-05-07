`timescale 1s/1ms

// ------------------ CLOCK MODULE ---------------------
module clock_12hr (
  input logic clk, rst,
  output logic [5:0] sec, min,
  output logic [4:0] hr,
  output logic is_am, is_pm,
  output logic [4:0] day,
  output logic [3:0] month,
  output logic [6:0] year,
  output logic [4:0] display_hr,
  output logic [4:0] hr_24
);

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      sec <= 0; min <= 0; hr_24 <= 0;
      day <= 1; month <= 1; year <= 24;
    end else begin
      sec <= sec + 1;
      if (sec == 59) begin
        sec <= 0;
        min <= min + 1;
        if (min == 59) begin
          min <= 0;
          hr_24 <= hr_24 + 1;
          if (hr_24 == 23) begin
            hr_24 <= 0;
            day <= day + 1;
            if (day == 31) begin
              day <= 1;
              month <= month + 1;
              if (month == 12) begin
                month <= 1;
                year <= year + 1;
              end
            end
          end
        end
      end
    end
  end

  always_comb begin
    if (hr_24 == 0) begin
      display_hr = 12; is_am = 1; is_pm = 0;
    end else if (hr_24 < 12) begin
      display_hr = hr_24; is_am = 1; is_pm = 0;
    end else if (hr_24 == 12) begin
      display_hr = 12; is_am = 0; is_pm = 1;
    end else begin
      display_hr = hr_24 - 12; is_am = 0; is_pm = 1;
    end
    hr = display_hr;
  end

endmodule

// ------------------ ALARM MODULE ---------------------
module alarm_system (
  input logic clk, rst,
  input logic [4:0] hr,
  input logic [5:0] min, sec,
  input logic [4:0] alarm_hr,
  input logic [5:0] alarm_min, alarm_sec,
  output logic alarm_buzzer
);

  always_ff @(posedge clk or posedge rst) begin
    if (rst)
      alarm_buzzer <= 0;
    else if (hr == alarm_hr && min == alarm_min && sec == alarm_sec)
      alarm_buzzer <= 1;
    else
      alarm_buzzer <= 0;
  end

endmodule

// ------------------ COUNTDOWN TIMER ---------------------
module countdown_timer (
  input logic clk, rst,
  input logic start_timer,
  input logic [5:0] timer_minutes,
  output logic [5:0] timer_min, timer_sec,
  output logic timer_active, timer_buzzer
);

  logic [11:0] total_secs;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      total_secs <= 0;
      timer_active <= 0;
      timer_buzzer <= 0;
    end else begin
      if (start_timer) begin
        total_secs <= timer_minutes * 60;
        timer_active <= 1;
        timer_buzzer <= 0;
      end else if (timer_active) begin
        if (total_secs > 0)
          total_secs <= total_secs - 1;
        if (total_secs == 1) begin
          timer_active <= 0;
          timer_buzzer <= 1;
        end
      end
    end
  end

  always_comb begin
    timer_min = total_secs / 60;
    timer_sec = total_secs % 60;
  end

endmodule

// ------------------ TESTBENCH ---------------------
module testbench;

  logic clk = 0;
  logic rst = 1;
  logic start_timer = 0;
  logic [5:0] timer_minutes = 1;
  logic [4:0] alarm_hr_set = 12;
  logic [5:0] alarm_min_set = 0;
  logic [5:0] alarm_sec_set = 10;

  logic [5:0] sec, min;
  logic [4:0] hr, display_hr, hr_24;
  logic is_am, is_pm;
  logic [4:0] day;
  logic [3:0] month;
  logic [6:0] year;

  logic [5:0] timer_min, timer_sec;
  logic timer_active, timer_buzzer;
  logic alarm_buzzer;

  // 1 Hz clock
  always #0.5 clk = ~clk;

  // Instantiate modules
  clock_12hr clkmod (
    .clk(clk), .rst(rst),
    .sec(sec), .min(min), .hr(hr),
    .is_am(is_am), .is_pm(is_pm),
    .day(day), .month(month), .year(year),
    .display_hr(display_hr), .hr_24(hr_24)
  );

  countdown_timer tmod (
    .clk(clk), .rst(rst),
    .start_timer(start_timer),
    .timer_minutes(timer_minutes),
    .timer_min(timer_min), .timer_sec(timer_sec),
    .timer_active(timer_active), .timer_buzzer(timer_buzzer)
  );

  alarm_system amod (
    .clk(clk), .rst(rst),
    .hr(display_hr), .min(min), .sec(sec),
    .alarm_hr(alarm_hr_set),
    .alarm_min(alarm_min_set),
    .alarm_sec(alarm_sec_set),
    .alarm_buzzer(alarm_buzzer)
  );

  initial begin
    $dumpfil("waveform.vcd");
    $dumpvars(0, testbench);

    // Reset
    #1 rst = 0;

    // Start timer
    #2 start_timer = 1;
    #1 start_timer = 0;

    // Let simulation run for ~70 seconds
    #70;

    $finish;
  end

endmodule

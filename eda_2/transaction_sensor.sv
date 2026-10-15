`ifndef __sensor_transaction
`define __sensor_transaction

//a transaction is the set of data transferred at a given moment on an interface
class transaction_sensor extends uvm_sequence_item;
  
  //register the transaction component in the factory
  `uvm_object_utils(transaction_sensor)
  
  rand bit[5:0] temperature;
  rand bit[6:0] humidity;
  rand bit[9:0] luminous_intensity;
  
  //class constructor; this function is called when an object of the transaction class is created
  function new(string name = "sequence_item_rename");//the name is arbitrary and is not used anywhere else
    super.new(name);  
    temperature = 23;
  	humidity = 0;
  	luminous_intensity = 0;
  endfunction
  
  //function that displays a transaction
  function void display_transaction_info();
    $display("Temperature: %0h, Humidity: %0h, Luminous intensity: %0h", temperature, humidity, luminous_intensity);
  endfunction
  
  function transaction_sensor copy();
	copy = new();
	copy.temperature = this.temperature;
	copy.humidity = this.humidity;
	copy.luminous_intensity = this.luminous_intensity;
	return copy;
  endfunction

endclass
`endif
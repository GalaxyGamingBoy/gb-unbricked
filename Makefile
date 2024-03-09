name := unbricked
deps := tiles/tiles.asm tiles/tilemap.asm tiles/logo.asm tiles/sprites.asm wram.asm

title := Unbricked
licensee := Marios Mitsios
version := 1

gameboy: $(name).gb
	echo "Applying Headers to: " ${name}
	rgbfix -v -t "$(title)" -k "$(licensee)" -i $(name) -n $(version) -p 0xFF $(name).gb

$(name).gb: $(name).o
	echo "Linking: " $(name)
	rgblink -o $(name).gb $(name).o

$(name).o: $(name).asm hardware.inc $(deps)
	echo "Assembling: " $(name)
	rgbasm -L -o $(name).o $(name).asm

hardware.inc:
	echo "hardware.inc not found, downloading..."
	wget https://raw.githubusercontent.com/gbdev/hardware.inc/master/hardware.inc

clean:
	rm $(name).o $(name).gb

run: $(name).gb
	Emulicious $(name).gb

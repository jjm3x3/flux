require "./gui_elements/button.rb"

describe "Button" do
    describe "intialize" do
        it "should construct" do
            # setup
            window_double = double("window")
            image_double = double("image", height: 10, width: 10)

            # execute
            Button.new(window_double, image_double, 1,1,1)

            # assert
            # nothing much to assert just making sure this works
        end
    end

    describe "draw" do
        it "should draw" do
            # setup
            window_double = double("window", mouse_x: 10, mouse_y: 10)
            image_double = double("image", height: 10, width: 10, draw: nil)
            sut = Button.new(window_double, image_double, 1,1,1, {is_pressed: ->() {} })

            # execute
            sut.draw

            # assert
            # nothing much to assert just making sure this works
        end

        it "should prefer drawing an image if one is injected" do
            # setup
            window_double = double("window", mouse_x: 10, mouse_y: 10)
            image_double = double("image", height: 10, width: 10, draw: nil)
            sut = Button.new(window_double, image_double, 1,1,1, {is_pressed: ->() {} })

            # execute
            sut.draw

            # assert
            expect(image_double).to have_received(:draw)
        end
    end

    describe "is_clicked?" do
        it "should intersect with image" do
            # setup
            window_double = double("window", mouse_x: 150 , mouse_y: 150)
            image_double = double("image", width: 200, height: 200)
            sut = Button.new(window_double, image_double, 1,1,1, {is_pressed: ->() {} })

            # execute
            result = sut.is_clicked?

            # assert
            expect(result).to be true
        end
    end

    describe "set_position" do
        it "should draw based what what is porvided in set_position" do
            # setup
            window_double = double("window", mouse_x: 10, mouse_y: 10)
            image_double = double("image", height: 10, width: 10, draw: nil)
            sut = Button.new(window_double, image_double, 1,1,1, {is_pressed: ->() {} })
            expected_x = 100
            expected_y = 100

            # execute
            sut.set_position(expected_x, expected_y)
            sut.draw

            # assert
            expected_x += 3  # accounts for buffer
            expected_y += 3  # accounts for buffer
            expect(image_double).to have_received(:draw).with(expected_x, expected_y, anything, anything, anything, anything)
        end
    end
end


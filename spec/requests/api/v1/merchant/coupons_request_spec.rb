require "rails_helper"

RSpec.describe "Merchant Coupon Endpoints" do
  let!(:merchant1) { create(:merchant) }
  let!(:merchant2) { create(:merchant) }

  let!(:customer1) { create(:customer) }

  let!(:invoice1) { create(:invoice, merchant: merchant2) }
  let!(:invoice2) { create(:invoice, merchant: merchant1) }
  let!(:invoice3) { create(:invoice, merchant: merchant1) }
  let!(:invoice4) { create(:invoice, merchant: merchant1) }
  
  let!(:coupon1) { create(:coupon, merchant: merchant1, invoice: invoice2) }
  let!(:coupon2) { create(:coupon, :with_percentage_discount, merchant: merchant1, invoice: invoice3) }
  let!(:coupon3) { create(:coupon, merchant: merchant2, invoice: invoice1) }
  let!(:coupon4) { create(:coupon, :deactivated, merchant: merchant1) }

  describe "Merchant Coupons Endpoints" do
    context "Merchant Coupons #Index" do
      it "can display all of a merchant's coupons" do
        get "/api/v1/merchants/#{merchant1.id}/coupons"
        coupons = JSON.parse(response.body, symbolize_names: true)
        expected_coupons = [coupon1, coupon2, coupon4]
        
        expect(coupons[:data].count).to eq(3)
        
        coupons[:data].each_with_index do |coupon_data, index|
          expected_coupon = expected_coupons[index]
      
          expect(coupon_data[:id]).to eq(expected_coupon.id.to_s)
          expect(coupon_data[:type]).to eq("coupon")
          expect(coupon_data[:attributes][:code]).to eq(expected_coupon.code)
          expect(coupon_data[:attributes][:status]).to eq(expected_coupon.status)
        end
      end
    end
    context "Merchant Coupon #Show" do
      it "can dispay information for a specific coupon" do
        get "/api/v1/merchants/#{merchant1.id}/coupons/#{coupon1.id}"
        coupon = JSON.parse(response.body, symbolize_names: true)
        expect(coupon[:data][:id]).to eq(coupon1.id.to_s)
        expect(coupon[:data][:type]).to eq("coupon")
        expect(coupon[:data][:attributes][:code]).to eq(coupon1.code)
        expect(coupon[:data][:attributes][:status]).to eq(coupon1.status)
        expect(coupon[:data][:attributes][:dollars_off]).to eq(coupon1.dollars_off)
      end
      it "cannot display incorrect information from a different coupon" do
        get "/api/v1/merchants/#{merchant1.id}/coupons/#{coupon1.id}"
        coupon = JSON.parse(response.body, symbolize_names: true)
        expect(coupon[:data][:id]).to_not eq(coupon2.id.to_s)
        expect(coupon[:data][:attributes][:code]).to_not eq(coupon3.code)
        expect(coupon[:data][:attributes][:status]).to_not eq(coupon4.status)
      end
      it "handles invalid "
    end
    context "Merchant Coupon #Create" do
      it "can create a new coupon" do
        get "/api/v1/merchants/#{merchant1.id}/coupons"
        coupons = JSON.parse(response.body, symbolize_names: true)
        expect(coupons[:data].count).to eq(3)
        
        post "/api/v1/merchants/#{merchant1.id}/coupons", params: {
          name: "Discount Coupon",
          code: "ITSACOUPON666420",
          percentage_off: 69,
          merchant_id: merchant1.id,
          invoice_id: invoice4.id
          }

        get "/api/v1/merchants/#{merchant1.id}/coupons"
        updated_coupons = JSON.parse(response.body, symbolize_names: true)
        expect(updated_coupons[:data].count).to eq(4)       
      end

      context "Sad Path coverage" do
        it "handles non-unique coupon code" do
          merchant6 = create(:merchant)
          create(:coupon, merchant: merchant6, code: "NOTVERYUNIQUECODE")

          post "/api/v1/merchants/#{merchant6.id}/coupons", params: {
            name: "Duplicate Code Coupon",
            code: "NOTVERYUNIQUECODE",
            percentage_off: 15,
            merchant_id: merchant6.id
          }

          expect(response).to have_http_status(:bad_request)
          error_response = JSON.parse(response.body, symbolize_names: true)
          expect(error_response[:error]).to eq('Coupon code must be unique')
        end

          it "handles missing discount param inputs" do
            post "/api/v1/merchants/#{merchant1.id}/coupons", params: {
              name: "Not A Single Discount",
              code: "ITSANAUGHTYCOUPON",
              merchant_id: merchant1.id
            }
          expect(response).to have_http_status(:unprocessable_entity)
          error_response = JSON.parse(response.body, symbolize_names: true)
          expect(error_response[:errors].first).to eq("Validation failed: A coupon must have a discount")
          end

          it "handles the presence of both discount params" do
            post "/api/v1/merchants/#{merchant1.id}/coupons", params: {
              name: "Too Many Discounts",
              code: "ALSOANAUGHTYCOUPON",
              percentage_off: 69,
              dollars_off: 420,
              merchant_id: merchant1.id,
              }
            expect(response).to have_http_status(:unprocessable_entity)
            error_response = JSON.parse(response.body, symbolize_names: true)
            expect(error_response[:errors].first).to eq("Validation failed: Enter either a dollar or a percentage discount, not both")             
          end

          it "handles a merchant already having 5 active coupons" do
            merchant3 = create(:merchant)
            5.times { create(:coupon, merchant: merchant3, status: :activated) }

            post "/api/v1/merchants/#{merchant3.id}/coupons", params: {
              name: "Too Many Active Coupons",
              code: "TOOMANYDANGCOUPONS",
              percentage_off: 1,
              merchant_id: merchant3.id
            }

            expect(response).to have_http_status(:bad_request)
            error_response = JSON.parse(response.body, symbolize_names: true)
            expect(error_response[:error]).to eq('Merchant already has 5 active coupons')
          end

          it "can still create deactivated coupons if merchant has 4 activated coupons and one deactivated coupon" do
            merchant3 = create(:merchant)
            4.times { create(:coupon, merchant: merchant3, status: :activated) }
            create(:coupon, merchant: merchant3, status: :deactivated)

            post "/api/v1/merchants/#{merchant3.id}/coupons", params: {
              name: "What if it one coupon isn't active",
              code: "ITWORKSIFITSNOTACTIVE",
              percentage_off: 99,
              merchant_id: merchant3.id,
            }

            get "/api/v1/merchants/#{merchant3.id}/coupons"
            updated_coupons = JSON.parse(response.body, symbolize_names: true)
            # binding.pry
            expect(updated_coupons[:data].count).to eq(6)

            active_coupons = updated_coupons[:data].select { |coupon| coupon[:attributes][:status] == 'activated' }
            expect(active_coupons.count).to eq(5)
          end
      end
    end
  end
end

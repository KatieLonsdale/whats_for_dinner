require 'meal_planner_prompt.rb'

class AIApiService
  def initialize(params)
    @client = Anthropic::Client.new(
      api_key: ENV['CLAUDE_API_KEY']
    )
    @params = params
  end

  def create_meal_plan
    prompt = MealPlannerPrompt.build(prompt_args)
    response = @client.messages.create(
      max_tokens: 8192,
      system: prompt[:system],
      messages: [{role: "user", content: prompt[:user]}],
      model: :"claude-opus-4-7"
    )

    raw_text = response.content.select { |b| b.type == "text"}.map(&:text).join
    parsed = JSON.parse(raw_text)

    { data: parsed }
  rescue JSON::ParserError => e
    { error: "Claude returned invalid JSON: #{e.message}" }
  rescue Anthropic::Error => e
    { error: "API error: #{e.message}" }
  end

  private
 
  def prompt_args
    {
      start_date:           @params[:start_date],
      end_date:             @params[:end_date],
      num_people:           @params[:num_people].to_i,
      dietary_preferences:  Array(@params[:dietary_preferences])
    }
  end

end
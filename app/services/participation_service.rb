class ParticipationService

  attr_reader :issue_result
  attr_reader :conversation_result

  attr_reader :issues
  attr_reader :conversations

  ISSUE_SQL = <<-sql
    select
      i.id as 'issue_id',
      i.name as 'issue_name',
      c.id as 'conversation_id'
    from
      issues i
    inner join
      conversations_issues ci
    on
      ci.issue_id = i.id
    inner join
      conversations c
    on
      ci.conversation_id = c.id
    order by
      i.id asc
    ;
  sql

  CONVERSATION_SQL = <<-sql
    select
      c.id as 'conversation',
      count(t.id) as 'contributions',
      count(distinct(t.owner)) as 'participants'
    from
      contributions t
    inner join
      conversations c
    on
      t.conversation_id = c.id
    where
      t.confirmed = 1
    group by
      c.id
    ;
  sql

  def conversations_by_issue(issue_id)
    load_issue_data if @issues.nil?
    count = 0
    count = @issues[issue_id.to_i][:conversations].size if @issues.has_key?(issue_id.to_i)
    return count
  end

  def contributions_by_issue(issue_id)
    load_issue_data if @issues.nil?

    count = 0
    if @issues.has_key?(issue_id.to_i)
      @issues[issue_id.to_i][:conversations].each do |conversation_id|
        count += @conversations[conversation_id][:contributions]
      end
    end

    return count

  end

  def participants_by_issue(issue_id)
    load_issue_data if @issues.nil?

    count = 0
    if @issues.has_key?(issue_id.to_i)
      issue = Issue.find(issue_id.to_i)
      @issues[issue_id.to_i][:conversations].each do |conversation_id|
        count += @conversations[conversation_id][:participants]
      end
      count += issue.participants.size
    end

    return count

  end

  private

  def load_issue_data

    @issue_result =  ActiveRecord::Base.connection.execute(ISSUE_SQL)
    @conversation_result =  ActiveRecord::Base.connection.execute(CONVERSATION_SQL)

    @issues = {}
    @issue_result.each do |i|
      unless @issues.has_key? i[0]
        @issues[i[0]] = {
          issue_id: i[0],
          issue_name: i[1],
          conversations: [i[2]]
        }
      else
        @issues[i[0]][:conversations] << i[2]
      end
    end

    @conversations = {}
    @conversation_result.each do |c|
      unless @conversations.has_key? [c[0]]
        @conversations[c[0]] = {
          conversation_id: c[0],
          contributions: c[1],
          participants: c[2]
        }
      end
    end

  end

end
